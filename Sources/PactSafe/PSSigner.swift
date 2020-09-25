//
//  PSSigner.swift
//  
//
//  Created by Tim Morse on 1/9/20.
//

import Foundation

@available(iOS 10.0, *)

public typealias PSSignerID = String

/// The PSSigner holds the signer ID and custom data that you'd like to be sent to PactSafe.
public struct PSSigner {
    
    /// The unique identifier of a Signer.
    public var signerId: PSSignerID
    
    /// The custom data associated with the Signer on the Activity.
    public var customData: PSCustomData
    
    public init(signerId: PSSignerID,
                customData: PSCustomData = PSCustomData()) {
        self.signerId = signerId
        self.customData = customData
    }
    
}
