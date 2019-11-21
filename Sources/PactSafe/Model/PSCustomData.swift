//
//  PSCustomData.swift
//  
//
//  Created by Tim Morse  on 9/17/19.
//

import Foundation
import UIKit

@available (iOS 10, *)
public struct PSCustomData: Codable {
    
    /// First Name name of the signer, which is a reserved property.
    
    
    /// First Name is a reserved property for custom data in PactSafe.
    public var first_name: String?
    
    /// Last Name is a reserved property for custom data in PactSafe.
    public var last_name: String?
    
    /// Company Name is a reserved property for custom data in PactSafe.
    public var company_name: String?
    
    /// Title is a reserved property for custom data in PactSafe.
    public var title: String?
    
    /// The name of the user's iOS device (e.g., iPhone 8).
    public var iosDeviceName: String
    
    /// The name of the iOS system name (e.g., iOS, tvOS, etc.)
    public var iosDeviceSystemName: String
    
    /// The system version number of the device (e.g, 11.0)
    public var iosDeviceSystemVersion: String
    
    /// The unique identifier that is unique and usable to this device.
    public var iosDeviceIdentifierForVendor: String
    
    /// The identifier of the device's current locale.
    public var iosLocaleIdentifier: String
    
    /// The regional code of the locale.
    public var iosLocaleRegionCode: String
    
    /// The current time zone identifier.
    public var iosTimeZoneIdentifier: String
    
    public init() {
        self.iosDeviceName = UIDevice.current.name
        self.iosDeviceSystemName = UIDevice.current.systemName
        self.iosDeviceSystemVersion = UIDevice.current.systemVersion
        self.iosDeviceIdentifierForVendor = UIDevice.current.identifierForVendor?.uuidString ?? ""
        self.iosLocaleIdentifier = Locale.current.identifier
        self.iosLocaleRegionCode = Locale.current.regionCode ?? ""
        self.iosTimeZoneIdentifier = TimeZone.current.identifier
    }
    
    func escapedCustomData() -> String? {
        let jsonData = try? JSONEncoder().encode(self)
        if let data = jsonData {
            let stringifyData = String(data: data, encoding: .utf8)
            
            return stringifyData
        } else {
            return nil
        }
    }
}
