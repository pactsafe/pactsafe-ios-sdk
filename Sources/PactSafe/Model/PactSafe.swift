import Foundation

public protocol PactSafeDelegate: AnyObject {
    func pactSafeContractsReceived(_ contractsData: Group?)
}

public class PactSafe {
    
    // MARK: - Properties
    public var accessToken: String = ""
    public var sid: String = ""
    public var testMode: Bool = false
    //TODO: Add some basic debug printing
    public var debug: Bool = false
    public weak var delegate: PactSafeDelegate?
    
    public static let sharedInstance = PactSafe()
    
    // MARK: -  Initializer
    private init() { }
    
    // MARK: - Methods
    // Only form of authorization is using site id
    public func sendActivity(signer sig: String,
                             siteId sid: String,
                               contracts cid: String?,
                               versionIds vid: String?,
                               eventType et: ActivityEvents,
                               groupId gid: String?,
                               emailConfirmation cnf: Bool? = false,
                               customData cus: CustomData?,
                               completion: @escaping(_ success: Bool, _ error: Error?, _ response: Data?) -> Void ) {
        // Uses Activity API
        var sendUrlContract = URLComponents()
        sendUrlContract.scheme = "https"
        sendUrlContract.host = PactSafeHostNames.activityAPI.rawValue
        sendUrlContract.path = "/send"
        sendUrlContract.queryItems = [
            URLQueryItem(name: "sig", value: escapeString(sig)),
            URLQueryItem(name: "cid", value: cid),
            URLQueryItem(name: "vid", value: vid),
            URLQueryItem(name: "et", value: et.rawValue),
            URLQueryItem(name: "gid", value: gid),
            URLQueryItem(name: "cnf", value: cnf?.description ?? ""),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: sid),
            URLQueryItem(name: "cus", value: cus?.escapedCustomData())
        ]
        
        guard let url = sendUrlContract.url else { return }
        sendData(with: url) { (success, error, data) in
            completion(success, error, data)
        }
    }
    
    // MARK: Get Latest Contracts Using Group Key
    public func getLatestContracts(usingGroup gKey: String,
                                   completion: @escaping(_ group: Group?, _ error: Error?) -> Void) {
        // Uses REST API
        var groupUrlConstruct = URLComponents()
        groupUrlConstruct.scheme = "https"
        groupUrlConstruct.host = PactSafeHostNames.restAPI.rawValue
        groupUrlConstruct.path = "/v1.1/groups/key::" + gKey
        groupUrlConstruct.queryItems = [
            URLQueryItem(name: "expand", value: "contracts,site")
        ]
        
        guard let url = groupUrlConstruct.url else { return }
        getData(fromURL: url) { (success, error, groupData) in
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
    public func getLatestSigned(usingSig sig: String,
                                groupKey gkey: String? = "",
                                contractIds cid: String? = "",
                                testMode tm: Bool? = false,
                                completion: @escaping(_ status: String) -> Void ) {
        // Uses Activity API
        var urlConstruct = URLComponents()
        urlConstruct.scheme = "https"
        urlConstruct.host = PactSafeHostNames.activityAPI.rawValue
        urlConstruct.path = "/latest"
        urlConstruct.queryItems = [
            URLQueryItem(name: "sig", value: escapeString(sig)),
            URLQueryItem(name: "gkey", value: gkey),
            URLQueryItem(name: "cid", value: cid),
            URLQueryItem(name: "tm", value: tm?.description ?? ""),
            URLQueryItem(name: "sid", value: self.sid)
        ]
        
        guard let url = urlConstruct.url else { return }
        getData(fromURL: url) { (success, error, data) in
            do {
                if let data = data {
                    let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool]
                    completion("\(String(describing: dicData))")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Get Contract Details
    public func getContractsDetails(withContractIds cids: [Int],
                                 completion: @escaping(_ Data: [Contracts?], _ error: Error?) -> Void) {
        
        let idsFormatted = cids.map { String($0) }.joined(separator: ",")
        let contractIdsFilter: String = "id==" + idsFormatted
        
        // Uses REST API
        var urlConstruct = URLComponents()
        urlConstruct.scheme = "https"
        urlConstruct.host =  PactSafeHostNames.restAPI.rawValue
        urlConstruct.path = "/v1.1/contracts"
        urlConstruct.queryItems = [
            URLQueryItem(name: "filter", value: contractIdsFilter),
            URLQueryItem(name: "expand", value: "published_version")
        ]
        
        guard let url = urlConstruct.url else { return }
        getData(fromURL: url) { (success, error, data) in
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
        }
    }
    
    
    // MARK: - Private Methods
    
    // MARK: Request Generation
    fileprivate func getData(fromURL url: URL,
                             completion: @escaping(_ success: Bool, _ error: Error?, _ response: Data?) -> Void) {
        
        let urlRequest = createGetUrlRequest(url)
        
        // Get data for urlRequest and return data or errors to completion handler
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                // TODO: Do better error handling
                completion(false, error, nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // TODO: Do something with the error code
                    return
            }
            if let data = data {
                completion(true, nil, data)
            }
        }
        task.resume()
    }
    
    fileprivate func sendData(with url: URL,
                              completion: @escaping(_ success: Bool, _ error: Error?, _ response: Data?) -> Void) {
        
        let urlRequest = createPostUrlRequest(url)
        
        // Send data for URLRequest and return data or errors to completion handler
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("got error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
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
    
    // MARK: Networking Helpers
    
    
    fileprivate func createGetUrlRequest(_ url: URL) -> URLRequest {
        // Create URLRequest that loads data from origin unless valid cache exists. Additionally, this uses the default iOS timeout of 60 seconds.
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60.0)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    fileprivate func createPostUrlRequest(_ url: URL) -> URLRequest {
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

