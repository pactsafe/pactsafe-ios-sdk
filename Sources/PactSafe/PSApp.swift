//
//  PSApp.swift
//
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation

@available(iOS 10.0, *)

/// The entry point of the PSApp SDK, which is accessible via the `shared` instance.
public class PSApp {
    
    // MARK: - Properties
    
    /**
            Used to configure your PSApp shared instance.

     - Important:
     This is required to be configured before using the PSApp shared instance.
     */
    open var authentication: PSAuthentication!
    
    /// The URLSessino that can be overriden before interacting with any methods.
    public var session: URLSession = URLSession.shared
    
    /// When `testMode` is set to true, data sent to PactSafe can be deleted witin the PactSafe app dashboard.
    public var testMode: Bool = false
    
    /// When set to true, additional errors will be printed from the device.
    public var debugMode: Bool = false
    
    private let queue = DispatchQueue(label: "PactSafeNetworking", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
    
    /// The shared instance of PSApp class.
    public static let shared: PSApp = {
        let instance = PSApp()
        return instance
    }()
    
    // MARK: -  Initializer
    private init( ) {}
    
    // MARK: - Activity API Methods
    
    public func sendActivity(_ type: PSActivityEvent,
                             signer: PSSigner,
                             group: PSGroup,
                             connectionData: PSConnectionData = PSConnectionData(),
                             testMode: Bool = false,
                             completion: @escaping(_ error: Error?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.activityAPI.rawValue
        urlComponents.path = "/send"
        
        let activityParameters = [
            URLQueryItem(name: "et", value: type.rawValue),
            URLQueryItem(name: "sig", value: signer.signerId),
            URLQueryItem(name: "cus", value: signer.customData.escapedCustomData()),
            URLQueryItem(name: "cid", value: group.contractsIds),
            URLQueryItem(name: "vid", value: group.contractVersions),
            URLQueryItem(name: "gid", value: "\(group.id)"),
            URLQueryItem(name: "cnf", value: group.confirmationEmail.description),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId)
        ]
        
        let connectionData = connectionData.urlQueryItems()
        urlComponents.queryItems = activityParameters + connectionData
        
        guard let url = urlComponents.url else {
            if self.debugMode { debugPrint(PSErrorMessages.constructUrlError) }
            return
        }
        
        sendData(with: url) { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /// Receive acceptance status of a specific signer id within a group.
    /// - Parameters:
    ///   - signerId: The unique identifier that is used to identify a user.
    ///   - groupKey: The group key is used to access specific details within a defined group in PactSafe.
    ///   - completion: The completion handler that gets called once the request is complete.
    ///   - needsAcceptance: Returns whether or not at least one contract within the group needs acceptance.
    ///   - contractsIds: Returns the contract ids that may need to be accepted.
    public func signedStatus(for signerId: PSSignerID,
                             groupKey: String,
                             completion: @escaping(_ needsAcceptance: Bool, _ contractsIds: [String]?) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.activityAPI.rawValue
        urlComponents.path = "/latest"
        urlComponents.queryItems = [
            URLQueryItem(name: "sig", value: signerId),
            URLQueryItem(name: "gkey", value: groupKey),
            URLQueryItem(name: "tm", value: self.testMode.description),
            URLQueryItem(name: "sid", value: self.authentication.siteAccessId)
        ]
        
        guard let url = urlComponents.url else {
            if self.debugMode { debugPrint(PSErrorMessages.constructUrlError) }
            return
        }
        
        getData(fromURL: url) { (result) in
            
            var needsAcceptance: Bool = false
            var contractIdsNeedAcceptance: [String] = []
            
            switch result {
            case .success(let data):
                do {
                    guard let dicData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool] else {
                        if self.debugMode { debugPrint(PSErrorMessages.jsonSerializationError) }
                        completion(needsAcceptance, nil)
                        return
                    }
                    for (id, accepted) in dicData {
                        if !accepted {
                            needsAcceptance = true
                            contractIdsNeedAcceptance.append(id)
                        }
                    }
                    completion(needsAcceptance, contractIdsNeedAcceptance)
                } catch {
                    completion(needsAcceptance, nil)
                }
            case .failure:
                completion(needsAcceptance, contractIdsNeedAcceptance)
            }
            
        }
    }
    
    public func loadGroup(groupKey: String,
                          completion: @escaping(_ group: PSGroup?, _ error: Error?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.activityAPI.rawValue
        urlComponents.path = "/load/json"
        urlComponents.queryItems = [
            URLQueryItem(name: "sid", value: authentication.siteAccessId),
            URLQueryItem(name: "gkey", value: groupKey)
        ]
        
        guard let url = urlComponents.url else {
            if self.debugMode { debugPrint(PSErrorMessages.constructUrlError) }
            return
        }
        
        getData(fromURL: url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try JSONDecoder().decode(PSGroup.self, from: data)
                    completion(decodedData, nil)
                } catch {
                    completion(nil, error)
                }
                
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Private Methods

    // MARK: Request Generation

    fileprivate func getData(fromURL url: URL,
                             completion: @escaping (Result<Data, Error>) -> Void) {
        
        queue.async {
            
            guard var urlRequest = self.authentication.authenticatedURLRequest(forURL: url) else { return }
            urlRequest.httpMethod = "GET"

            // Get data for urlRequest and return data or errors to completion handler.
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<Data, Error>
                
                if let error = error {
                    if self.debugMode { debugPrint(error as Any) }
                    result = .failure(error)
                } else if let error = self.error(from: response) {
                    if self.debugMode { debugPrint(response as Any) }
                    result = .failure(error)
                } else if let data = data {
                    result = .success(data)
                } else {
                    result = .failure(PSNetworkError.noDataOrError)
                }
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            task.resume()
            
        }
    }

    fileprivate func sendData(with url: URL,
                              completion: @escaping (Result<Data, Error>) -> Void) {
        
        queue.async {
            
            guard var urlRequest = self.authentication.authenticatedURLRequest(forURL: url) else { return }
            urlRequest.httpMethod = "POST"
            
            // Send data for URLRequest and return data or errors to completion handler.
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<Data, Error>
                
                if let error = error {
                    if self.debugMode { debugPrint(error as Any)}
                    result = .failure(error)
                } else if let error = self.error(from: response) {
                    if self.debugMode { debugPrint(response as Any)}
                    result = .failure(error)
                } else if let data = data {
                    result = .success(data)
                } else {
                    result = .failure(PSNetworkError.noDataOrError)
                }
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            task.resume()
            
        }
    }
    
    // MARK: Authentication Check
    internal func assertSetup() {
        guard authentication != nil else {
            assertionFailure("ERROR: This request requires authentication using your PactSafe Access ID.")
            return
        }
    }
    
    // MARK: Helpers
    private func error(from response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }

        let statusCode = response.statusCode

        if statusCode >= 200 && statusCode <= 299 {
            return nil
        } else {
            return "Invalid server status code: \(statusCode)" as? Error
        }
    }
}
