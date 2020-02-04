//
//  PSGroup.swift
//  
//
//  Created by Tim Morse on 1/2/20.
//

import Foundation

// MARK: - GroupData
public struct PSGroup: Codable {
    
    // MARK: - Private or unused properties
    private let type, containerSelector, signerIDSelector, formSelector: String?
    private let renderID: String?
    private let forceScroll, autoRun: Bool?
    
    /// Unusued and is currently always false.
    private let triggered: Bool?
    
    /// Note: Unused for the iOS SDK.
    /// The setting of whether all contracts should be displayed immediately.
    /// A contract will only be displayed if the signer hasn't accepted the latest version.
    private let displayAll: Bool?
    
    
    // MARK: - Public properties
    /// The group key.
    public let key: String
    
    /// The ID of the group.
    public let id: Int
    
    /// The contract IDs that are part of the group.
    public let contracts: [Int]
    
    /// The contract version IDs that are part of the group.
    public let versions: [String]
    
    /// The major version ID of the contract
    public let majorVersions: [String]
    
    /// The clickwrap style of the group.
    public let style: String?
    
    /// The current setting for whether the form submission should be blocked.
    public let blockFormSubmission: Bool
    
    /// The alert message to be displayed when acceptance is required.
    public let alertMessage: String
    
    /// The URL of the legal center for the PactSafe site.
    public let legalCenterURL: String
    
    /// The acceptance language that is set within the group's settings.
    public let acceptanceLanguage: String
    
    /// The contracts data where the contract ID is the key.
    public let contractData: [String: PSContract]?
    
    /// The time (in epoch) of when the group was fetched.
    public let renderedTime: Int
    
    /// The rendered HTML of the clickwrap.
    public let contractHTML: String?
    
    /// The locale of the group.
    public let locale: String?
    
    /// The current setting within the group for whether a confirmation should be sent upon acceptance.
    public let confirmationEmail: Bool
    
    /// The contract IDs separated by a`,` and returned as a string.
    public var contractsIds: String {
        return contracts.map( { String($0) } ).joined(separator: ",")
    }
    
    /// The contract versions separated by a `,` and returned as a string.
    public var contractVersions: String? {
        return versions.joined(separator: ",")
    }

    enum CodingKeys: String, CodingKey {
        case key
        case type
        case style
        case id = "group"
        case containerSelector = "container_selector"
        case signerIDSelector = "signer_id_selector"
        case formSelector = "form_selector"
        case blockFormSubmission = "block_form_submission"
        case forceScroll = "force_scroll"
        case alertMessage = "alert_message"
        case confirmationEmail = "confirmation_email"
        case triggered
        case legalCenterURL = "legal_center_url"
        case acceptanceLanguage = "acceptance_language"
        case contractData = "contract_data"
        case contracts, versions
        case majorVersions = "major_versions"
        case renderID = "render_id"
        case renderedTime = "rendered_time"
        case autoRun = "auto_run"
        case displayAll = "display_all"
        case contractHTML = "contract_html"
        case locale
    }
    
    
    /// Returns the acceptance language without the specified parameter.
    /// This can be useful when wanting to remove handlebars set within the group setting.
    /// - Parameter parameter: The string you want to remove from the acceptance language.
    public func cleanAcceptanceLanguage(of parameter: String) -> String {
        return acceptanceLanguage.replacingOccurrences(of: parameter, with: "")
    }
}
