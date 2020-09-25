//
//  PSApp.swift
//
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation

@available(iOS 10.0, *)

/// The entry point of the PSApp SDK, which is accessible via the `shared` instance.
public final class PSApp {
    
    // MARK: - Properties
    /// The URLSession that can be overriden before interacting with any methods.
    public var session: URLSession = URLSession.shared
    
    /// The PactSafe Site Access ID.
    public var siteAccessId: String?
    
    /// When `testMode` is set to true, data sent to PactSafe can be deleted witin the PactSafe dashboard.
    public var testMode: Bool = false
    
    /// When set to true, additional errors will be printed.
    public var debugMode: Bool = false
    
    /// Queue created specifically due to Clickwrap potentially being rendered by user interaction or initiation.
    private let queue = DispatchQueue(label: "PactSafeNetworking", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
    
    /// Whether a group was preloaded or not.
    /// Note: this does not guarantee group data exists in memory.
    public var preloaded: Bool = false
    
    /// Result handler using the Result enum. Returns Data on Success  Error.
    private typealias DataHandler = (Result<Data, Error>) -> Void
    
    /// The shared instance of PSApp class.
    public static let shared: PSApp = {
        let instance = PSApp()
        return instance
    }()
    
    // MARK: -  Initializer
    private init() {}
    
    /// Configure the PactSafe App using the PactSate Site Access ID.
    /// - Parameter siteAccessId: The PactSafe Site Access ID found in your PactSafe Site settings.
    public func configure(siteAccessId: String) {
        self.siteAccessId = siteAccessId
    }
    
    // MARK: - Methods
    
    /// Preload PactSafe Group data into memory. This does not guarantee data stays within memory.
    /// - Parameters:
    ///   - groupKey: The Group key for the Group data you want to load.
    ///   - refreshCacheData: Whether you want to refresh data that has potentially been cached previously by prior use of this method.
    ///   - completion: Optional completion handler indicating whether the Group has preloaded or not.
    public func preload(withGroupKey groupKey: String,
                        refreshCacheData: Bool = false,
                        completion: ((Bool) -> ())? = nil) {
        
        assertSetup()
        
        let urlComponents = groupUrlComponents(groupKey: groupKey)
        if let url = urlComponents.url {
            getData(fromURL: url, tryCache: !refreshCacheData, cacheResponse: true) { (result) in
                switch result {
                case .success:
                    self.preloaded = true;
                    if let completion = completion {
                        completion(true)
                    }
                case .failure(let error):
                    self.printDebug(error)
                    self.preloaded = false
                    if let completion = completion {
                        completion(false)
                    }
                }
            }
        } else {
            printDebug(PSErrorMessages.constructUrlError)
            if let completion = completion {
                completion(false)
            }
        }
    }
    
    /// Send an Activity to the PactSafe platform.
    /// - Parameters:
    ///   - type: The type of Activity to be sent.
    ///   - signer: A unique ID for the Signer.
    ///   - group: The Group Data that includes information about the contract(s) and associated version(s).
    ///   - connectionData: Additional data that gets sent as part of the Activity for the record.
    ///   - testMode: Whether to send the Activity in test mode or not.
    ///   - completion: A completion handler that notifies you when the Activity has sent. If an error occurs, it will be returned as part of the handler.
    public func sendActivity(_ type: PSActivityEvent,
                             signer: PSSigner,
                             group: PSGroup,
                             connectionData: PSConnectionData = PSConnectionData(),
                             testMode: Bool = false,
                             completion: @escaping(_ error: Error?) -> Void) {
        
        assertSetup()
        
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
            URLQueryItem(name: "tm", value: testMode.description),
            URLQueryItem(name: "sid", value: siteAccessId)
        ]
        
        let connectionData = connectionData.urlQueryItems()
        urlComponents.queryItems = activityParameters + connectionData
        
        if let url = urlComponents.url {
            sendData(with: url) { (result) in
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        } else {
            printDebug(PSErrorMessages.constructUrlError)
            completion(PSErrorMessages.constructUrlError)
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
        
        assertSetup()
        
        let urlComponents = latestUrlComponents(signerId: signerId, groupKey: groupKey)
        
        if let url = urlComponents.url {
            getData(fromURL: url) { (result) in
                var needsAcceptance: Bool = false
                var contractIdsNeedAcceptance: [String] = []
                switch result {
                case .success(let data):
                    do {
                        if let dicData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool] {
                            dicData.forEach { (id, accepted) in
                                if !accepted {
                                    needsAcceptance = true
                                    contractIdsNeedAcceptance.append(id)
                                }
                            }
                            completion(needsAcceptance, contractIdsNeedAcceptance)
                        } else {
                            self.printDebug(PSErrorMessages.jsonSerializationError)
                        }
                    } catch {
                        self.printDebug(error)
                        completion(needsAcceptance, nil)
                    }
                case .failure(let error):
                    self.printDebug(error)
                    completion(needsAcceptance, contractIdsNeedAcceptance)
                }
            }
        } else {
            printDebug(PSErrorMessages.constructUrlError)
            completion(false, nil)
        }
    }
    
    
    /// Retrieve Group data using a Group Key.
    /// - Parameters:
    ///   - groupKey: The Group Key for the Group you want to load.
    ///   - completion: A completion handler that returns Group data or an error if an error occurs.
    public func loadGroup(groupKey: String,
                          completion: @escaping(_ group: PSGroup?, _ error: Error?) -> Void) {
        
        assertSetup()
        
        let urlComponents = groupUrlComponents(groupKey: groupKey)
        
        if let url = urlComponents.url {
            getData(fromURL: url) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(PSGroup.self, from: data)
                        completion(decodedData, nil)
                    } catch {
                        self.printDebug(error)
                        completion(nil, error)
                    }
                case .failure(let error):
                    self.printDebug(error)
                    completion(nil, error)
                }
            }
        } else {
            printDebug(PSErrorMessages.constructUrlError)
            completion(nil, PSErrorMessages.constructUrlError)
        }
    }
    
    // MARK: - Private Methods
    private func latestUrlComponents(signerId: PSSignerID, groupKey: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.activityAPI.rawValue
        urlComponents.path = "/latest"
        urlComponents.queryItems = [
            URLQueryItem(name: "sig", value: signerId),
            URLQueryItem(name: "gkey", value: groupKey),
            URLQueryItem(name: "tm", value: testMode.description),
            URLQueryItem(name: "sid", value: siteAccessId)
        ]
        return urlComponents
    }
    
    private func groupUrlComponents(groupKey: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = PSHostName.activityAPI.rawValue
        urlComponents.path = "/load/json"
        urlComponents.queryItems = [
            URLQueryItem(name: "sid", value: siteAccessId),
            URLQueryItem(name: "gkey", value: groupKey)
        ]
        return urlComponents
    }

    // MARK: Request Generation
    private func getData(fromURL url: URL,
                         tryCache: Bool = false,
                         cacheResponse: Bool = false,
                         completion: @escaping DataHandler) {
        
        queue.async {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let urlCache = URLCache.shared
            if tryCache, let cachedResponse = urlCache.cachedResponse(for: urlRequest) {
                completion(.success(cachedResponse.data))
            } else {
                // Get data for urlRequest and return data or errors to completion handler.
                let task = self.session.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        self.printDebug(error)
                        completion(.failure(error))
                    } else if let error = self.error(from: response) {
                        self.printDebug(response)
                        completion(.failure(error))
                    } else if let data = data {
                        if cacheResponse { self.cacheUrlResponse(urlResponse: response, urlRequest: urlRequest, data: data) }
                        completion(.success(data))
                    } else {
                        self.printDebug(PSNetworkError.noDataOrError)
                        completion(.failure(PSNetworkError.noDataOrError))
                    }
                }
                task.resume()
            }
        }
    }

    private func sendData(with url: URL,
                          completion: @escaping DataHandler) {
        
        queue.async {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Send data for URLRequest and return data or errors to completion handler.
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    self.printDebug(error)
                    completion(.failure(error))
                } else if let error = self.error(from: response) {
                    self.printDebug(response)
                    completion(.failure(error))
                } else if let data = data {
                    completion(.success(data))
                } else {
                    self.printDebug(PSNetworkError.noDataOrError)
                    completion(.failure(PSNetworkError.noDataOrError))
                }
            }
            task.resume()
        }
    }
    
    private func cacheUrlResponse(urlResponse response: URLResponse?,
                                  urlRequest: URLRequest,
                                  data: Data) {
        let urlCache = URLCache.shared
        guard let response = response else {
            printDebug(PSErrorMessages.responseCachingError)
            return
        }
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: .allowedInMemoryOnly)
        urlCache.storeCachedResponse(cachedResponse, for: urlRequest)
    }
    
    private func printDebug(_ message: Any?) {
        if self.debugMode, let message = message {
            if let error = message as? Error {
                debugPrint(error.localizedDescription)
            } else {
                debugPrint(message)
            }
        }
    }
    
    // MARK: Authentication Check
    internal func assertSetup() {
        guard siteAccessId != nil else {
            assertionFailure("ERROR: This request requires authentication using your PactSafe Access ID.")
            return
        }
    }
    
    // MARK: Helpers
    private func error(from response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else { return nil }

        let statusCode = response.statusCode
        if statusCode >= 200 && statusCode <= 299 {
            return nil
        } else {
            return PSNetworkError.notFoundError
        }
    }
}
