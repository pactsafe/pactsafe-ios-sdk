//
//  PSAuthentication.swift
//  
//
//  Created by Tim Morse  on 10/16/19.
//

import Foundation
import UIKit

public class PSAuthentication {
    
    public let accessToken: String
    public let siteAccessId: String
    
    fileprivate let userAgent = Bundle.main.userAgent
    
    public init(accessToken: String, siteAccessId: String) {
        self.accessToken = accessToken
        self.siteAccessId = siteAccessId
    }
    
    /// Adds the appropriate authentication to the URL request.
    /// - Parameter url: The URL that's needed to generate an authenticated URL Request.
    open func authenticatedURLRequest(forURL url: URL) -> URLRequest? {
        
        var urlRequest = URLRequest(url: url);
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
}

extension Bundle {
    internal var userAgent: String {
        let infoDictionary = self.infoDictionary
        let appName = infoDictionary?["CFBundleName"] as? String ?? "MissingBundle"
        let appID = infoDictionary?["CFBundleIdentifier"] as? String ?? "MissingBundleID"
        let appVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? "MissingAppVersion"
        let device = UIDevice.current
        let agent = String(format:"%@ %@ (%@ %@ - %@, %@)", appName, appVersion, device.systemName , device.systemVersion, device.model, appID)
        
        return agent
    }
}

extension HTTPURLResponse {
    var infoDictionary: [AnyHashable: Any] {
        return [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)]
    }
}
