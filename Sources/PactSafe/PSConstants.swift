//
//  PSConstants.swift
//  
//
//  Created by Tim Morse  on 10/7/19.
//

import Foundation

/**
        The PactSafe API Hostname.
 
 - Important:
     The SDK currently only supports the Activity API. Have feedback on what else you'd like to see? Please let us know by contacting us.
 */
public enum PSHostName: String {
    case activityAPI = "pactsafe.io"
    // case restAPI = "api.pactsafe.com"
}

/// The available activity events to send to the PactSafe API.
public enum PSActivityEvent: String {
    case agreed = "agreed"
    case displayed = "displayed"
    case updated = "updated"
    case visited = "visited"
    case sent = "sent"
    case disagreed = "disagreed"
}

/// Used to configure the clickwrap style.
public enum PSClickWrapStyle: String {
    case combined
    case noCheckbox
}

/// The error messages used throughout the PactSafe SDK.
enum PSErrorMessages: String {
    case constructUrlError = "Error constructing URL."
    case sendActivitySendError = "Error sending data."
    case missingSiteAccesId = "Missing Site Access ID."
    case decodingError = "Error decoding data."
    case encodingError = "Error encoding data."
    case jsonSerializationError = "Error serializing data into JSON."
}

/// Networking error messages.
enum PSNetworkError: Error {
    case noDataOrError
}
