//
//  PSAdditionalData.swift
//  
//
//  Created by Tim Morse  on 10/7/19.
//

import Foundation

public enum PactSafeHostNames: String {
    case activityAPI = "pactsafe.io"
    case restAPI = "api.pactsafe.com"
}

public enum ActivityEvents: String {
    case agreed = "agreed"
    case displayed = "displayed"
    case updated = "updated"
    case visited = "visited"
    case sent = "sent"
    case disagreed = "disagreed"
}

/// Alerts the style of the clickwrap that is loaded.
public enum ClickWrapStyle: String {
    case checkbox = "checkbox"
    case combined = "combined"
    case full = "full"
}
