//
//  PSApp.swift
//
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation
import Network

@available(iOS 10.0, *)
public class PSApp {
    
    // MARK: - Properties
    
    /**
            Used to configure your PSApp shared instance.

     - Important:
     This is required to be configured before using the PSApp shared instance.
     */
    open var authentication: PSAuthentication!
    
    /// When `testMode` is set to true, data sent to PactSafe can be deleted witin the PactSafe app dashboard.
    public var testMode: Bool = false
    
    /// When set to true, additional information on errors will be printed.
    public var debugMode: Bool = false
    
    /// Shared instance of PSApp class.
    public static let shared = PSApp()
    
    /// Allows for custom data formatting.
    fileprivate let dataHelpers = PSDataHelpers()

    // MARK: -  Initializer
    private init() { }
    
    // MARK: - Activity API Methods
    
    public func send(activity activityType: PSActivityEvent,
                     signerId: String,
                     contractIds: [Int]?,
                     contractVersions: [String]?,
                     groupId: String?,
                     emailConfirmation: Bool? = false,
                     customSignerData: PSCustomData?,
                     completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.activityAPI.rawValue
        urlComponents.path = "/send"
        urlComponents.queryItems = [
            URLQueryItem(name: "sig", value: signerId),
            URLQueryItem(name: "cid", value: dataHelpers.formatContractIds(contractIds)),
            URLQueryItem(name: "vid", value: dataHelpers.formatContractVersions(contractVersions)),
            URLQueryItem(name: "et", value: activityType.rawValue),
            URLQueryItem(name: "gid", value: groupId),
            URLQueryItem(name: "cnf", value: emailConfirmation?.description ?? "false"),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId),
            URLQueryItem(name: "cus", value: customSignerData?.escapedCustomData()),
        ]

        guard let url = urlComponents.url else { return }
        
        sendData(with: url) { (data, response, error) in
            if self.debugMode && error != nil {
                debugPrint(error as Any)
            }
            completion(data, response, error)
        }
    }
    
    public func sendActivity(activiyType type: PSActivityEvent,
                             signerId: String,
                             completion: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
    }
    
    /// Receive acceptance status of a specific signer id within a group.
    /// - Parameters:
    ///   - signerId: A unique identifier that is used when needing to identify a user.
    ///   - groupKey: The group key is used to access specific details within a defined group in PactSafe.
    ///   - completion: The completion handler that gets called once an API request is complete.
    ///   - needsAcceptance: Will return whether or not at least one contract within the group needs acceptance.
    ///   - contractsIds: The `contractIds` will give you the unique contract ids that need to be accepted.
    public func signedStatus(for signerId: String,
                             in groupKey: String,
                             completion: @escaping(_ needsAcceptance: Bool, _ contractsIds: [Int]?) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.qaActivityApi.rawValue
        urlComponents.path = "/latest"
        urlComponents.queryItems = [
            URLQueryItem(name: "sig", value: signerId),
            URLQueryItem(name: "gkey", value: groupKey),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId)
        ]
        
        guard let url = urlComponents.url else { return }
        
        getData(fromURL: url) { (data, response, error) in
            var needsAcceptance: Bool = false
            var contractIdsNeedAcceptance: [Int] = []
            
            if error != nil {
                if self.debugMode { debugPrint(error as Any) }
            } else {
                guard let data = data else {
                    completion(needsAcceptance, nil)
                    return
                }
                
                do {
                    if let dicData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool] {
                        for (key, value) in dicData {
                            if !value {
                                needsAcceptance = true
                                if let idAsInt = Int(key) {
                                   contractIdsNeedAcceptance.append(idAsInt)
                                }
                            }
                        }
                        completion(needsAcceptance, contractIdsNeedAcceptance)
                    }
                } catch {
                    completion(needsAcceptance, nil)
                }
            }
        }
    }
    
    public func loadGroup(groupKey gKey: String,
                          completion: @escaping(_ group: PSGroupData?, _ error: Error?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.qaActivityApi.rawValue
        urlComponents.path = "/load/json"
        urlComponents.queryItems = [
            URLQueryItem(name: "sid", value: authentication.siteAccessId),
            URLQueryItem(name: "gkey", value: gKey)
        ]
        
        guard let url = urlComponents.url else { return }
        
        getData(fromURL: url) { (data, response, error) in
            if error != nil {
                if self.debugMode { debugPrint(error as Any) }
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, nil)
                    return
                }
                
                do {
                    let decodedGroupData = try JSONDecoder().decode(PSGroupData.self, from: data)
                    completion(decodedGroupData, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    // MARK: - Private Methods

    // MARK: Request Generation

    fileprivate func getData(fromURL url: URL,
                             completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        guard var urlRequest = authentication.authenticatedURLRequest(forURL: url) else { return }
        urlRequest.httpMethod = "GET"

        // Get data for urlRequest and return data or errors to completion handler
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200 ... 299).contains(httpResponse.statusCode) else {
                    completion(nil, response, nil)
                    return
            }
            if let data = data {
                completion(data, nil, nil)
            }
        }
        task.resume()
    }

    fileprivate func sendData(with url: URL,
                              completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        guard var urlRequest = authentication.authenticatedURLRequest(forURL: url) else { return }
        urlRequest.httpMethod = "POST"
        
        // Send data for URLRequest and return data or errors to completion handler
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200 ... 299).contains(httpResponse.statusCode) else {
                completion(nil, response, nil)
                return
            }
            if let data = data {
                completion(data, nil, nil)
            }
        }
        task.resume()
    }
    
    // MARK: Authentication Check
    internal func assertSetup() {
        guard authentication != nil else {
            fatalError("ERROR: This request requires authentication using your PactSafe Access ID.")
        }
    }
}
