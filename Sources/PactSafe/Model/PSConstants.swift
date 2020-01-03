//
//  PSConstants.swift
//  
//
//  Created by Tim Morse  on 10/7/19.
//

import Foundation

public enum PSHostName: String {
    case activityAPI = "pactsafe.io"
    case restAPI = "api.pactsafe.com"
    case qaActivityApi = "qa.pactsafe.io"
}

public enum PSActivityEvent: String {
    case agreed = "agreed"
    case displayed = "displayed"
    case updated = "updated"
    case visited = "visited"
    case sent = "sent"
    case disagreed = "disagreed"
}

/// Alerts the style of the clickwrap that is loaded.
public enum PSClickWrapStyle: String {
    case checkbox = "checkbox"
    case combined = "combined"
    case full = "full"
}

public enum PSErrorMessages: String {
    case constructUrlError = "Error constructing URL."
    case sendActivitySendError = "Error sending data."
    case contructingURLError = "Issue Constructing URL"
    case missingSiteAccesId = "Missing Site Access ID"
    case missingAccessToken = "Missing Access Token"
}
