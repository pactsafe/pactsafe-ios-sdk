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
    
    /// The name of the user's iOS device (e.g., John Doe's iPhone 8).
    private let iosDeviceName: String
    
    /// First Name is a reserved property for custom data in PactSafe.
    public var firstName: String?
    
    /// Last Name is a reserved property for custom data in PactSafe.
    public var lastName: String?
    
    /// Company Name is a reserved property for custom data in PactSafe.
    public var companyName: String?
    
    /// Title is a reserved property for custom data in PactSafe.
    public var title: String?
    
    /// Returns a new initialized object containing the name of the device
    /// with the option to set additonal custom data to the Activity.
    public init() {
        self.iosDeviceName = UIDevice.current.name
    }
        
    /// Escapes data to pass through to the PactSafe Activity API.
    public func escapedCustomData() -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try? encoder.encode(self)
        if let data = jsonData {
            let stringifyData = String(data: data, encoding: .utf8)
            return stringifyData
        } else {
            return nil
        }
    }
}
