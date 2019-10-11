import Foundation

public protocol PSAppDelegate: AnyObject {
    func pactSafeContractsReceived(_ contractsData: Group?)
}

public class PSApp {
    // MARK: - Properties

    // Configure Authentication
    public var accessToken: String = ""
    
    public var sid: String = ""
    
    // Configure Development Properties
    public var testMode: Bool = false
    
    // TODO: Add some basic debug printing
    public var debug: Bool = false
    
    // TODO: Do we need a delegate here with completion handlers?
    public weak var delegate: PSAppDelegate?

    // TODO: Decide if we go the shared instance route or not...
    public static let sharedInstance = PSApp()

    // MARK: -  Initializer

    private init() {}

    // MARK: - Methods

    public func sendActivity(forSignerId signerId: String,
                             activityType type: PSActivityEvent,
                             withSiteId siteId: String,
                             _ contractIds: [Int]?,
                             _ versionIds: [String]?,
                             _ groupId: String?,
                             emailConfirmation confirmation: Bool? = false,
                             customSignerData data: CustomData?,
                             completion: @escaping (_ success: Bool, _ error: Error?, _ response: Data?) -> Void) {
        
        // Uses Activity API
        var sendUrlContract = URLComponents()
        sendUrlContract.scheme = "https"
        sendUrlContract.host = PSHostName.activityAPI.rawValue
        sendUrlContract.path = "/send"
        sendUrlContract.queryItems = [
            URLQueryItem(name: "sig", value: escapeString(signerId)),
            URLQueryItem(name: "cid", value: formatContractIds(contractIds)),
            URLQueryItem(name: "vid", value: formatContractVersions(versionIds)),
            URLQueryItem(name: "et", value: type.rawValue),
            URLQueryItem(name: "gid", value: groupId),
            URLQueryItem(name: "cnf", value: confirmation?.description ?? "false"),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: siteId),
            URLQueryItem(name: "cus", value: data?.escapedCustomData()),
        ]

        guard let url = sendUrlContract.url else { return }
        sendData(with: url) { success, error, data in
            completion(success, error, data)
        }
    }
    
    // Persist Signed Contract Versions
    private func persistAgreed(contractVersions versions: [String]) {
        
    }

    // MARK: Get Latest Contracts Using Group Key

    public func getLatestContracts(byGroupKey groupKey: String,
                                   completion: @escaping (_ group: Group?, _ error: Error?) -> Void) {
        // Uses REST API
        // TODO: move to Activity API with /json
        var groupUrlConstruct = URLComponents()
        groupUrlConstruct.scheme = "https"
        groupUrlConstruct.host = PSHostName.restAPI.rawValue
        groupUrlConstruct.path = "/v1.1/groups/key::" + groupKey
        groupUrlConstruct.queryItems = [
            URLQueryItem(name: "expand", value: "contracts,site"),
        ]

        guard let url = groupUrlConstruct.url else { return }
        getData(fromURL: url) { _, _, groupData in
            do {
                guard let jsonData = groupData else { return }
                let decoder = JSONDecoder()
                let decodedGroupData = try? decoder.decode(Group.self, from: jsonData)
                self.delegate?.pactSafeContractsReceived(decodedGroupData)
                completion(decodedGroupData, nil)
            } catch {
                completion(nil, nil)
            }
        }
    }

    // MARK: Get Latest Contracts Signed

    // Requires site id
    public func getLatestSigned(forSignerId signerId: String,
                                inGroupKey groupKey: String? = "",
                                _ contractIds: [Int]? = nil,
                                testMode tm: Bool? = false,
                                _ siteAccessId: String,
                                completion: @escaping ([String: Bool]?) -> Void) {
        
        // Uses Activity API
        var urlConstruct = URLComponents()
        urlConstruct.scheme = "https"
        urlConstruct.host = PSHostName.activityAPI.rawValue
        urlConstruct.path = "/latest"
        urlConstruct.queryItems = [
            URLQueryItem(name: "sig", value: escapeString(signerId)),
            URLQueryItem(name: "gkey", value: groupKey),
            URLQueryItem(name: "cid", value: formatContractIds(contractIds)),
            URLQueryItem(name: "tm", value: tm?.description ?? ""),
            URLQueryItem(name: "sid", value: siteAccessId),
        ]

        guard let url = urlConstruct.url else { return }
        getData(fromURL: url) { _, error, data in
            do {
                if let data = data {
                    let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool]
                    if let dicData = dicData {
                        completion(dicData)
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func presentUpdatedContracts(withContractIds contractIds: [Int]) {
        
        getContractsDetails(withContractIds: contractIds) { (contractDetails, error) in
            for contract in contractDetails {
                guard let contract = contract else { return }
                
                if contract.publishedVersion.changeSummary != "" {
                    print(contract.publishedVersion.changeSummary)
                }
            }
        }
        
    }

    // MARK: Get Contract Details

    public func getContractsDetails(withContractIds contractIds: [Int],
                                    completion: @escaping (_ Data: [Contracts?], _ error: Error?) -> Void) {
        
        // TODO: Add error messaging here
        guard let idsFormatted = formatContractIds(contractIds) else { return }
        let contractIdsFilter: String = "id==" + idsFormatted

        // Uses REST API
        var urlConstruct = URLComponents()
        urlConstruct.scheme = "https"
        urlConstruct.host = PSHostName.restAPI.rawValue
        urlConstruct.path = "/v1.1/contracts"
        urlConstruct.queryItems = [
            URLQueryItem(name: "filter", value: contractIdsFilter),
            URLQueryItem(name: "expand", value: "published_version"),
        ]

        guard let url = urlConstruct.url else { return }
        
        getData(fromURL: url) { success, error, data in
            if success {
                do {
                    var returnContracts: [Contracts?] = []
                    guard let jsonData = data else { return }
                    let decoder = JSONDecoder()
                    let decodedContractsData = try? decoder.decode(ContractsResponse.self, from: jsonData)
                    if let contractsData = decodedContractsData?.data {
                        for contract in contractsData {
                            returnContracts.append(contract)
                        }
                    }
                    completion(returnContracts, nil)
                } catch {
                    completion([nil], error)
                }
            } else {
                print("Getting contract details failed.")
            }
            
        }
    }

    // MARK: - Private Methods

    // MARK: Request Generation

    fileprivate func getData(fromURL url: URL,
                             completion: @escaping (_ success: Bool, _ error: Error?, _ response: Data?) -> Void) {
        let urlRequest = createGetUrlRequest(withURL: url)

        // Get data for urlRequest and return data or errors to completion handler
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                // TODO: Do better error handling
                completion(false, error, nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200 ... 299).contains(httpResponse.statusCode) else {
                // TODO: Do something with the error code
                    completion(false, error, nil)
                return
            }
            if let data = data {
                completion(true, nil, data)
            }
        }
        task.resume()
    }

    fileprivate func sendData(with url: URL,
                              completion: @escaping (_ success: Bool, _ error: Error?, _ response: Data?) -> Void) {
        let urlRequest = createPostUrlRequest(withURL: url)

        // Send data for URLRequest and return data or errors to completion handler
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("got error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200 ... 299).contains(httpResponse.statusCode) else {
                // TODO: Do better error handling
                print("response was: \(String(describing: response))")
                return
            }
            if let data = data {
                completion(true, nil, data)
            }
        }
        task.resume()
    }

    // MARK: Data Helpers

    private func escapeString(_ input: String) -> String {
        let originalString = input
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        return escapedString
    }
    
    private func formatContractIds(_ contractIds: [Int]?) -> String? {
        guard let contractIds = contractIds else { return nil }
        
        let formattedIds = contractIds.map { String($0) }.joined(separator: ",")
        return formattedIds
    }
    
    private func formatContractVersions(_ contractVersions: [String]?) -> String? {
        guard let contractVersions = contractVersions else { return nil }
        
        let formattedVersions = contractVersions.map { String($0) }.joined(separator: ",")
        return formattedVersions
    }

    // MARK: Networking Helpers

    fileprivate func createGetUrlRequest(withURL url: URL) -> URLRequest {
        // For caching behavior, it uses the protocol cache policy
        // TODO: Check to ensure this caching behavior is what we want
        // Additionally, this uses the default iOS timeout of 60 seconds
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    fileprivate func createPostUrlRequest(withURL url: URL) -> URLRequest {
        if accessToken == "" {
            assert(true, "Access token cannot be empty.")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
