//
//  PSCustomData.swift
//  
//
//  Created by Tim Morse  on 9/17/19.
//

import Foundation

@available (iOS 10, *)

/// The custom data that is sent as part of the activity to PactSafe.
public struct PSCustomData {
    
    /// First Name is a reserved property for custom data in PactSafe but can be set.
    public var firstName: String?
    
    /// Last Name is a reserved property for custom data in PactSafe but can be set.
    public var lastName: String?
    
    /// Company Name is a reserved property for custom data in PactSafe but can be set.
    public var companyName: String?
    
    /// Title is a reserved property for custom data in PactSafe but can be set.
    public var title: String?
    
    /// Used to store default custom data keys/values and manually added key/value pairs.
    private let allCustomData: NSMutableDictionary = NSMutableDictionary()
    
    /// Returns a new initialized object containing the name of the device
    /// with the option to set additonal custom data to the Activity.
    public init() {}
    
    
    /// Add a custom data attribute to the record.
    /// - Parameters:
    ///   - key: The name of the property.
    ///   - value: The value of the property.
    public func add(withKey key: String, value: Any) {
        allCustomData.setValue(value, forKey: key)
    }
    
    /// Remove a custom data attribute by it's key.
    /// - Parameter key: The name of the property.
    public func remove(forKey key: String) {
        allCustomData.removeObject(forKey: key)
    }

    /// Escapes data to pass through to the PactSafe Activity API.
    public func escapedCustomData() -> String? {
        if let firstName = firstName {
            allCustomData.setValue(firstName, forKey: "firstName")
        }
        if let lastName = lastName {
            allCustomData.setValue(lastName, forKey: "lastName")
        }
        if let companyName = companyName {
            allCustomData.setValue(companyName, forKey: "companyName")
        }
        if let title = title {
            allCustomData.setValue(title, forKey: "title")
        }
        do {
            let jsonObj = try JSONSerialization.data(withJSONObject: allCustomData, options: [])
            let jsonString = String(data: jsonObj, encoding: .utf8)
            return jsonString
        } catch {
            print(error)
            return nil
        }
    }
    
}
