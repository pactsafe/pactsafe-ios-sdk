//
//  Contract.swift
//  
//
//  Created by Tim Morse  on 9/25/19.
//

import Foundation

public struct Contract {
    
    public var id: Int
    public var title: String? = nil
    public var publishedVersion: String
    public var latestVersion: String
    public var isPublic: Bool
    public var tags: [String?]
    public var contractKey: String
    
    public init(_ id: Int,
                _ title: String? = nil,
                _ publishedVersion: String,
                _ latestVersion: String,
                _ isPublic: Bool,
                _ tags: [String?],
                _ contractKey: String
                ) {
        self.id = id
        self.title = title
        self.publishedVersion = publishedVersion
        self.latestVersion = latestVersion
        self.isPublic = isPublic
        self.tags = tags
        self.contractKey = contractKey
    }
    
}
