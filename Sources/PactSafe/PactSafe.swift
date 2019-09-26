import Foundation

public struct PactSafe {
    
    fileprivate var sid: String
    fileprivate var accessToken: String
    private let session: URLSession
    
    public init(_ sid: String, _ accessToken: String) {
        self.accessToken = accessToken
        self.sid = sid
        self.session = URLSession()
    }
    
    public func sendAcceptance(signer sig: String,
                               contracts cid: String,
                               versionIds vid: String,
                               eventType et: String,
                               groupId gid: String,
                               emailConfirmation cnf: Bool,
                               customData cus: CustomData,
                               testMode tm: Bool
    ) {
        
    }
    
    public func getLatestContractsFromGroup(groupKey gKey: String) {
        var groupUrlConstruct = URLComponents()
        groupUrlConstruct.scheme = "https"
        groupUrlConstruct.host = "api.pactsafe.com"
        groupUrlConstruct.path = "/v1.1/groups/key::" + gKey
        groupUrlConstruct.query = "expand=contracts,site"
        
        guard let url = groupUrlConstruct.url else { return }
        getGroupData(url) { (success, error, groupData) in
            print("Should have gottne group data")
        }
    }
    
    // MARK: Request Generation
    fileprivate func getGroupData(_ url: URL, completion: @escaping(_ success: Bool, _ error: Error?, _ response: Group?) -> Void) {
        
        let urlRequest = createGetUrlRequest(url)
        
        // Get data for urlRequest and return data or errors to completion handler
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                // Do something with the error
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // Do something with the error code
                    return
            }
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(json)
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
        urlRequest.addValue("Application/JSON", forHTTPHeaderField: "Content-Type")
        urlRequest.networkServiceType = NSURLRequest.NetworkServiceType.responsiveData
        return urlRequest
    }
}

extension PactSafe {
    public enum PactSafeEndpoints: String {
        case latestSignedVersions = "https://pactsafe.io/latest"
        case latestPublishedContracts = "https://pactsafe.io/published"
        case signedContractsByUser = "https://pactsafe.io/retrieve"
        case sendAcceptance = "https://pactsafe.io/send"
        case latestContractsByGroup = "https://api.pactsafe.com/v1.1/groups"
    }
}
