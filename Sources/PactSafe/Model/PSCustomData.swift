//
//  CustomData.swift
//  
//
//  Created by Tim Morse  on 9/17/19.
//

import Foundation
import UIKit

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
    
    public init() {
        self.iosDeviceName = UIDevice.current.name
        self.iosDeviceSystemName = UIDevice.current.systemName
        self.iosDeviceSystemVersion = UIDevice.current.systemVersion
        self.iosDeviceIdentifierForVendor = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    func escapedCustomData() -> String? {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(self)
        
        guard let data = jsonData else { return nil }
        
        let stringifyData = String(data: data, encoding: .utf8)
        
        return stringifyData
    }
}
