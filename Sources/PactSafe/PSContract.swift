//
//  PSContract.swift
//  
//
//  Created by Tim Morse on 1/30/20.
//

import Foundation

public struct Contract: Codable {
    
    /// The version ID of the published contract.
    public let publishedVersion: String
    
    /// The title of the contract.
    public let title: String
    
    /// The key of the contract, which can be useful when needing
    /// to directly link to it in your legal center.
    public let key: String
    
    /// The change summary (if provided) of the published contract.
    public let changeSummary: String?

    enum CodingKeys: String, CodingKey {
        case publishedVersion = "published_version"
        case title, key
        case changeSummary = "change_summary"
    }
}
