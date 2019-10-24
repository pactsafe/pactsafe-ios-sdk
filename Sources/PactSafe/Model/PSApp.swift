//
//  PSApp.swift
//
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation

@available(iOS 10.0, *)
public class PSApp {
    // MARK: - Properties
    
    // Configure Authentication
    open var authentication: PSAuthentication!
    
    // Configure Development Properties
    public var testMode: Bool = false
    
    // TODO: Add some basic debug printing
    public var debugMode: Bool = false

    // TODO: Decide if we go the shared instance route or not...
    public static let shared = PSApp()
    
    private let dataHelpers = PSDataHelpers()

    // MARK: -  Initializer
    private init() { }
    
    // MARK: - Activity API Methods
    
    public func sendActivity(signerId: String,
                             activityType: PSActivityEvent,
                             contractIds: [Int]?,
                             contractVersions: [String]?,
                             groupId: String?,
                             emailConfirmation: Bool? = false,
                             customSignerData: PSCustomData?,
                             completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        // Uses Activity API
        var sendUrlContract = URLComponents()
        sendUrlContract.scheme = "https"
        sendUrlContract.host = PSHostName.activityAPI.rawValue
        sendUrlContract.path = "/send"
        sendUrlContract.queryItems = [
            URLQueryItem(name: "sig", value: dataHelpers.escapeString(signerId)),
            URLQueryItem(name: "cid", value: dataHelpers.formatContractIds(contractIds)),
            URLQueryItem(name: "vid", value: dataHelpers.formatContractVersions(contractVersions)),
            URLQueryItem(name: "et", value: activityType.rawValue),
            URLQueryItem(name: "gid", value: groupId),
            URLQueryItem(name: "cnf", value: emailConfirmation?.description ?? "false"),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId),
            URLQueryItem(name: "cus", value: customSignerData?.escapedCustomData()),
        ]

        guard let url = sendUrlContract.url else { return }
        
        sendData(with: url) { (data, response, error) in
            if self.debugMode && error != nil {
                debugPrint(error as Any)
            }
            completion(data, response, error)
        }
    }
    
    // Get Latest Signed
    // TODO: Adjust to have multiple outputs to simplify work needed by developer? 
    public func getLatestSigned(forSignerId signerId: String,
                                inGroupKey groupKey: String?,
                                _ contractIds: [Int]?,
                                completion: @escaping ([String: Bool]?) -> Void) {
        
        // Uses Activity API
        var urlConstruct = URLComponents()
        urlConstruct.scheme = "https"
        urlConstruct.host = PSHostName.activityAPI.rawValue
        urlConstruct.path = "/latest"
        urlConstruct.queryItems = [
            URLQueryItem(name: "sig", value: dataHelpers.escapeString(signerId)),
            URLQueryItem(name: "gkey", value: groupKey),
            URLQueryItem(name: "cid", value: dataHelpers.formatContractIds(contractIds)),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId),
        ]

        guard let url = urlConstruct.url else { return }
        
        getData(fromURL: url) { (data, response, error) in
            if error == nil {
                do {
                    if let data = data {
                        let dicData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool]
                        if let dicData = dicData {
                            completion(dicData)
                        } else {
                            completion(nil)
                        }
                    }
                } catch {
                    completion(nil)
                }
            } else {
                if self.debugMode{
                    debugPrint(error as Any)
                }
                completion(nil)
            }
        }
    }
    
    public func getSignedStatus(for signerId: String,
                                in groupKey: String,
                                completion: @escaping(_ needsAcceptance: Bool, _ contractsIds: [Int]?) -> Void) {
        
        var urlConstruct = URLComponents()
        urlConstruct.scheme = "https"
        urlConstruct.host = PSHostName.activityAPI.rawValue
        urlConstruct.path = "/latest"
        urlConstruct.queryItems = [
            URLQueryItem(name: "sig", value: dataHelpers.escapeString(signerId)),
            URLQueryItem(name: "gkey", value: groupKey),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId)
        ]
        
        guard let url = urlConstruct.url else { return }
        
        getData(fromURL: url) { (data, response, error) in
            var needsAcceptance: Bool = false
            var contractIdsNeedAcceptance: [Int] = []
            if error == nil {
                do {
                    if let data = data {
                        let dicData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool]
                        if let dicData = dicData {
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
                    }
                } catch {
                    completion(needsAcceptance, nil)
                }
            } else {
                if self.debugMode {
                    debugPrint(error as Any)
                }
                completion(needsAcceptance, nil)
            }
        }
    }

    // MARK: - REST API Methods
    
    // Get Latest Contracts Using Group Key
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
        getData(fromURL: url) { (data, response, error) in
            if error == nil {
                do {
                    guard let jsonData = data else { return }
                    let decoder = JSONDecoder()
                    let decodedGroupData = try decoder.decode(Group.self, from: jsonData)
                    completion(decodedGroupData, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                if self.debugMode {
                    debugPrint(error as Any)
                }
                completion(nil, error)
            }
        }
    }

    // MARK: Get Contract Details
    
    // TODO: Ensure we have contract ids or throw error

    public func getContractsDetails(withContractIds contractIds: [Int],
                                    completion: @escaping (_ Data: [Contracts?], _ error: Error?) -> Void) {
        
        // TODO: Add error messaging here
        guard let idsFormatted = dataHelpers.formatContractIds(contractIds) else { return }
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
        
        getData(fromURL: url) { (data, response, error) in
            if error == nil {
                do {
                    var returnContracts: [Contracts] = []
                    guard let jsonData = data else { return }
                    let decoder = JSONDecoder()
                    let decodedContractsData = try decoder.decode(ContractsResponse.self, from: jsonData)
                    let contractsData = decodedContractsData.data
                    for contract in contractsData {
                        returnContracts.append(contract)
                    }
                    completion(returnContracts, nil)
                } catch {
                    completion([nil], error)
                }
            } else {
                if self.debugMode {
                    debugPrint(error as Any)
                }
                completion([nil], error)
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
