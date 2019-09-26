//
//  Group.swift
//  
//
//  Created by Tim Morse  on 9/25/19.
//

import Foundation

public struct Group {
    
    private var id: Int
    public var name: String
    public var groupKey: String?
    public var contracts: [Contract?]
    
    public init(_ id: Int, _ groupKey: String?, _ name: String, _ contracts: [Contract?]) {
        self.id = id
        self.groupKey = groupKey
        self.name = name
        self.contracts = contracts
    }
    
//    init?(json: [String: Any]) {
//        guard let jsonData = json["data"] as? [String: Any] else { return nil }
//        let id = jsonData["id"] as? Int
//        let name = jsonData["name"] as? String
//        guard let contractsJSON = jsonData["contracts"] as? [String: Any] else { return nil }
//
//
//    }
}
