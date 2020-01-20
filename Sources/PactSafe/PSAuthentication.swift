//
//  PSAuthentication.swift
//  
//
//  Created by Tim Morse  on 10/16/19.
//

import Foundation
import UIKit

public class PSAuthentication {
    
    /// The PactSafe Site Access ID that is required for making requests with the PactSafe Activity API.
    public let siteAccessId: String
    
    /// Additional information that is passed along about the device and app.
    fileprivate let userAgent = Bundle.main.userAgent
    
    /// The initializer used for authentication with PactSafe API services.
    /// - Parameter siteAccessId: The PactSafe Site Access ID which is located in your PactSafe settings [here](https://app.pactsafe.com/settings/account).
    public init(siteAccessId: String) {
        self.siteAccessId = siteAccessId
    }
    
    /// Adds the appropriate authentication to a URL request.
    /// - Parameter url: The URL that's needed to generate an authenticated URL Request.
    open func authenticatedURLRequest(forURL url: URL) -> URLRequest? {
        var urlRequest = URLRequest(url: url);
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
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
        let agent = String(format:"%@ %@ (%@ %@ - %@, %@)", appName, appVersion, device.systemName, device.systemVersion, device.model, appID)
        return agent
    }
}

extension HTTPURLResponse {
    var infoDictionary: [AnyHashable: Any] {
        return [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)]
    }
}
