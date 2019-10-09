//
//  CustomData.swift
//  
//
//  Created by Tim Morse  on 9/17/19.
//

import Foundation

public struct CustomData: Codable {
    
    /// First Name name of the signer, which is a reserved property.
    public var first_name: String?
    public var last_name: String?
    public var company_name: String?
    public var title: String?
    
    public init() { }
    
    func escapedCustomData() -> String? {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(self)
        
        guard let data = jsonData else { return nil }
        
        let stringifyData = String(data: data, encoding: .utf8)!
        
        if let escapedString = stringifyData.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return escapedString
        } else {
            return nil
        }
    }
}
