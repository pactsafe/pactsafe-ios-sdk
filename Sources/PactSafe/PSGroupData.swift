//
//  PSGroupData.swift
//  
//
//  Created by Tim Morse on 1/2/20.
//

import Foundation

// MARK: - GroupData
public struct PSGroupData: Codable {
    
    private let type, containerSelector, signerIDSelector, formSelector, renderID: String?
    private let forceScroll, autoRun: Bool?
    
    public let key: String
    public let id: Int
    public let contracts: [Int]
    public let versions: [String]
    public let majorVersions: [String]
    
    public let style: String?
    public let blockFormSubmission: Bool?
    public let alertMessage: String?
    public let confirmationEmail: Bool?
    public let triggered: Bool?
    public let legalCenterURL: String?
    public let acceptanceLanguage: String?
    public let contractData: [String: Contract]?
    public let renderedTime: Int?
    public let displayAll: Bool?
    public let contractHTML: String?
    public let locale: String?
    
    public var contractsIds: String {
        return contracts.map( { String($0) } ).joined(separator: ",")
    }
    
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
    
    public func cleanAcceptanceLanguage(of parameter: String) -> String? {
        guard let acceptanceLanguage = acceptanceLanguage else { return nil }
        return acceptanceLanguage.replacingOccurrences(of: parameter, with: "")
    }
}


public struct Contract: Codable {
    public let publishedVersion, title, key, changeSummary: String?

    enum CodingKeys: String, CodingKey {
        case publishedVersion = "published_version"
        case title, key
        case changeSummary = "change_summary"
    }
}
