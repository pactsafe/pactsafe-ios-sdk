//
//  File.swift
//  
//
//  Created by Tim Morse  on 10/17/19.
//

import Foundation

public struct PSDataHelpers {
    
    public func escapeString(_ input: String) -> String {
        let originalString = input
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        return escapedString
    }
    
    public func formatContractIds(_ contractIds: [Int]?) -> String? {
        guard let contractIds = contractIds else { return nil }
        let formattedIds = contractIds.map { String($0) }.joined(separator: ",")
        return formattedIds
    }
    
    public func formatContractVersions(_ contractVersions: [String]?) -> String? {
        guard let contractVersions = contractVersions else { return nil }
        let formattedVersions = contractVersions.map { String($0) }.joined(separator: ",")
        return formattedVersions
    }
    
}
