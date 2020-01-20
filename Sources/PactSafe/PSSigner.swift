//
//  PSSigner.swift
//  
//
//  Created by Tim Morse on 1/9/20.
//

import Foundation

@available(iOS 10.0, *)

public typealias PSSignerID = String

public struct PSSigner {
    
    public var signerId: PSSignerID
    public var customData: PSCustomData
    
    public init(signerId: PSSignerID, customData: PSCustomData = PSCustomData()) {
        self.signerId = signerId
        self.customData = customData
    }
    
}
