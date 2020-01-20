//
//  PSDataHelpers.swift
//  
//
//  Created by Tim Morse  on 10/17/19.
//

import Foundation

struct PSDataHelpers {
    
    func escapeString(_ input: String) -> String {
        let originalString = input
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        return escapedString
    }
    
    func formatContractIds(_ contractIds: [String]?) -> String? {
        guard let contractIds = contractIds else { return nil }
        let formattedIds = contractIds.map { String($0) }.joined(separator: ",")
        return formattedIds
    }
    
    func formatContractVersions(_ contractVersions: [String]?) -> String? {
        guard let contractVersions = contractVersions else { return nil }
        let formattedVersions = contractVersions.map { String($0) }.joined(separator: ",")
        return formattedVersions
    }
    
}
