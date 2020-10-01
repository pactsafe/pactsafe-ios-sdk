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
enum PSErrorMessages: Error {
    case constructUrlError
    case sendActivitySendError
    case missingSiteAccesId
    case decodingError
    case encodingError
    case jsonSerializationError
    case responseCachingError
    case noGroupDataError
    case sendAgreedError
}

extension PSErrorMessages: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .constructUrlError:
            return NSLocalizedString("Error constructing URL.", comment: "")
        case .sendActivitySendError:
            return NSLocalizedString("Error sending data.", comment: "")
        case .missingSiteAccesId:
            return NSLocalizedString("Missing Site Access ID.", comment: "")
        case .decodingError:
            return NSLocalizedString("Error decoding data.", comment: "")
        case .encodingError:
            return NSLocalizedString("Error encoding data.", comment: "")
        case .jsonSerializationError:
            return NSLocalizedString("Error serializing data into JSON.", comment: "")
        case .responseCachingError:
            return NSLocalizedString("Issue caching URLResponse.", comment: "")
        case .noGroupDataError:
            return NSLocalizedString("Error loading group data.", comment: "")
        case .sendAgreedError:
            return NSLocalizedString("Error sending an agreed activity to PactSafe.", comment: "")
        }
    }
}

/// Networking error messages.
enum PSNetworkError: Error {
    case noDataOrError
    case notFoundError
    case preloadFailed
}

extension PSNetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noDataOrError:
            return NSLocalizedString("Networking error.", comment: "")
        case .notFoundError:
            return NSLocalizedString("Object not found", comment: "")
        case .preloadFailed:
            return NSLocalizedString("Preloading failed.", comment: "")
        }
    }
}
