//
//  CustomData.swift
//  
//
//  Created by Tim Morse  on 9/17/19.
//

import Foundation
import UIKit

@available (iOS 10, *)
public struct PSCustomData: Codable {
    
    /// First Name name of the signer, which is a reserved property.
    public var first_name: String?
    public var last_name: String?
    public var company_name: String?
    public var title: String?
    
    public var iosDeviceName: String
    public var iosDeviceSystemName: String
    public var iosDeviceSystemVersion: String
    public var iosDeviceIdentifierForVendor: String
    public var iosLocaleIdentifier: String
    public var iosLocaleRegionCode: String
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
