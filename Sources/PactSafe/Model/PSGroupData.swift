//
//  PSGroupData.swift
//  
//
//  Created by Tim Morse on 1/2/20.
//

import Foundation

// MARK: - GroupData
public struct PSGroupData: Codable {
    public let key: String?
    public let type: String?
    public let style: String?
    public let group: Int
    public let containerSelector, signerIDSelector, formSelector: String?
    public let blockFormSubmission, forceScroll: Bool?
    public let alertMessage: String?
    public let confirmationEmail, triggered: Bool?
    public let legalCenterURL: String?
    public let acceptanceLanguage: String?
    public let contractData: [String: Contract]?
    public let contracts: [Int]?
    public let versions, majorVersions: [String]?
    public let renderID: String?
    public let renderedTime: Int?
    public let autoRun, displayAll: Bool?
    public let contractHTML: String?
    public let locale: String?

    enum CodingKeys: String, CodingKey {
        case key
        case type
        case style
        case group
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
}

// TODO: RENAME TO CONTRACT
public struct Contract: Codable {
    public let publishedVersion, title, key, changeSummary: String?

    enum CodingKeys: String, CodingKey {
        case publishedVersion = "published_version"
        case title, key
        case changeSummary = "change_summary"
    }
}
