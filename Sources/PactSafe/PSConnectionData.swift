//
//  PSConnectionData.swift
//  
//
//  Created by Tim Morse on 1/9/20.
//

#if canImport(UIKit)
import UIKit

/// The connection data that is sent to PactSafe as part of an activity.
public struct PSConnectionData: Codable {
    
    /// The client library being used that is sent to PactSafe.
    private let clientLibrary: String = "PactSafe iOS SDK"
    
    /// The client library version being used that is sent to PactSafe
    private let clientVersion: String = "1.0.1"
    
    /// The unique identifier that is unique and usable to this device.
    private let deviceFingerprint: String
    
    /// The mobile device category being used (e.g,. tablet or mobile).
    private let environment: String
    
    /// The operating system and version of the  device.
    private let operatingSystem: String
    
    /// The screen resolution of the device.
    private let screenResolution: String
    
    /// The current locale identifier of the device.
    public var browserLocale: String
    
    /// The current time zone identifier of the device.
    public var browserTimezone: String
    
    /// The domain of the page being viewed. Note: This is normally for web pages but is available to be populated if needed.
    public var pageDomain: String?
    
    /// The path of the page being viewed. Note: This is normally for web pages but is available to be populated if needed.
    public var pagePath: String?
    
    /// The query path on the page being viewed. Note: This is normally for web pages but is available to be populated if needed.
    public var pageQuery: String?
    
    /// The title of the page being viewed. Note: This is normally for web pages but is available to be populated if you'd
    /// like to use the title of the screen where the PactSafe activity is occurring.
    public var pageTitle: String?
    
    /// The URL of the page being viewed. Note: This is normally for web pages but is available to be populated if needed.
    public var pageUrl: String?
    
    /// The referred of the page being viewed. Note: This is normally for web pages but is avaialble to be populated if needed.
    public var referrer: String?
    
    public init() {
        self.deviceFingerprint = UIDevice.current.identifierForVendor?.uuidString ?? ""
        self.environment = UIDevice.current.model.contains("iPad") ? "tablet" : "mobile"
        self.operatingSystem = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        self.screenResolution = "\(Int(UIScreen.main.bounds.width)) x \(Int(UIScreen.main.bounds.height))"
        self.browserLocale = Locale.current.identifier
        self.browserTimezone = TimeZone.current.identifier
    }
    
    public func urlQueryItems() -> [URLQueryItem] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if #available(iOS 11.0, *) { encoder.outputFormatting = .sortedKeys }
        guard let jsonData = try? encoder.encode(self) else { return []}
        guard let serialization = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: String] else { return [] }
        var queryItems: [URLQueryItem] = []
        for (key, value) in serialization {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        return queryItems
    }
    
}
#endif
