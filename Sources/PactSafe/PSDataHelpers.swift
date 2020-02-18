//
//  PSDataHelpers.swift
//  
//
//  Created by Tim Morse  on 10/17/19.
//

import Foundation

struct PSDataHelpers {
    
    /// Escapes a string before being sent to the API.
    func escapeString(_ input: String) -> String {
        input.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    /// Formats the contract ids.
    func formatContractIds(_ contractIds: [String]?) -> String? {
        guard let contractIds = contractIds else { return nil }
        return contractIds.map { String($0) }.joined(separator: ",")
    }
    
    /// Formats the contract versions.
    func formatContractVersions(_ contractVersions: [String]?) -> String? {
        guard let contractVersions = contractVersions else { return nil }
        return contractVersions.map { String($0) }.joined(separator: ",")
    }
    
}
