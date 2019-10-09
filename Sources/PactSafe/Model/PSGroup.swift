//
//  PSGroup.swift
//  
//
//  Created by Tim Morse  on 9/25/19.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
public struct Group: Codable {
    public let data: DataClass
}

// MARK: - DataClass
public struct DataClass: Codable {
    let deleted, published: Bool
    let publishedTime: String
    let paused, pendingChanges: Bool
    let tags: [JSONAny]
    let type, style: String
    let blockSubmission, forceScroll, autoRun, displayAll: Bool
    let alertMessage: String
    let confirmationEmail, hideRecordSummary: Bool
    let targetJurisdictions: [JSONAny]
    let position: String
    let openLegalCenter, alwaysVisible: Bool
    public let contracts: [Contract]
    let dataDynamic: Bool
    let key, name: String
    let createdBy, updatedBy, account: Int
    public let site: Site
    let createdTime, updatedTime: String
    let screenshots: [JSONAny]
    public let acceptanceLanguage: String?
    let publishedEndpoint: String
    let publishedBy: Int
    public let id: Int

    enum CodingKeys: String, CodingKey {
        case deleted, published
        case publishedTime = "published_time"
        case paused
        case pendingChanges = "pending_changes"
        case tags, type, style
        case blockSubmission = "block_submission"
        case forceScroll = "force_scroll"
        case autoRun = "auto_run"
        case displayAll = "display_all"
        case alertMessage = "alert_message"
        case confirmationEmail = "confirmation_email"
        case hideRecordSummary = "hide_record_summary"
        case targetJurisdictions = "target_jurisdictions"
        case position
        case openLegalCenter = "open_legal_center"
        case alwaysVisible = "always_visible"
        case contracts
        case dataDynamic = "dynamic"
        case key, name
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case account, site
        case createdTime = "created_time"
        case updatedTime = "updated_time"
        case screenshots
        case acceptanceLanguage = "acceptance_language"
        case publishedEndpoint = "published_endpoint"
        case publishedBy = "published_by"
        case id
    }
}

public struct ContractsResponse: Codable {
    let page, perPage, count, totalCount: Int
    let hasMore: Bool
    public let data: [Contracts]

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case count
        case totalCount = "total_count"
        case hasMore = "has_more"
        case data
    }
}

public struct Contracts: Codable {
    let deleted, published: Bool
    let publishedTime: String
    let protected, contractPrivate, contractPublic, shared: Bool
    let classification, type: String
    let tags: [JSONAny]
    let key, title: String
    let createdBy, updatedBy, account, site: Int
    let createdTime, updatedTime, downloadEndpoint, latestVersion: String
    let publishedBy: Int
    public let publishedVersion: PublishedVersion
    let id: Int

    enum CodingKeys: String, CodingKey {
        case deleted, published
        case publishedTime = "published_time"
        case protected
        case contractPrivate = "private"
        case contractPublic = "public"
        case shared, classification, type, tags, key, title
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case account, site
        case createdTime = "created_time"
        case updatedTime = "updated_time"
        case downloadEndpoint = "download_endpoint"
        case latestVersion = "latest_version"
        case publishedBy = "published_by"
        case publishedVersion = "published_version"
        case id
    }
}

// MARK: - Contract
public struct Contract: Codable {
    let deleted, published: Bool
    let publishedTime: String
    let protected, contractPrivate, contractPublic, shared: Bool
    let classification, type: String
    let tags: [JSONAny]
    public let key, title: String
    let createdBy, updatedBy, account, site: Int
    let createdTime, updatedTime, downloadEndpoint: String
    public let latestVersion: String
    let publishedBy: Int
    let publishedVersion: String
    public let id: Int

    enum CodingKeys: String, CodingKey {
        case deleted, published
        case publishedTime = "published_time"
        case protected
        case contractPrivate = "private"
        case contractPublic = "public"
        case shared, classification, type, tags, key, title
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case account, site
        case createdTime = "created_time"
        case updatedTime = "updated_time"
        case downloadEndpoint = "download_endpoint"
        case latestVersion = "latest_version"
        case publishedBy = "published_by"
        case publishedVersion = "published_version"
        case id
    }
}

// MARK: - PublishedVersion
public struct PublishedVersion: Codable {
    let minorVersionNumber: Int
    let isMajorVersion, published: Bool
    let publishedTime, effectiveTime: String
    let deprecatedTime: JSONNull?
    public let body: String
    let protected: Bool
    public let type: String
    let publishedVersionDynamic: Bool
    let status, changeSummary: String
    let notifySigners: Bool
    let tokens: [JSONAny]
    public let title: String
    let createdBy, updatedBy, account, site: Int
    let contract, versionNumber: Int
    let createdTime, updatedTime: String
    let fields: [JSONAny]
    let downloadEndpoint, editorVersion, fullVersionNumber: String
    let majorVersion: JSONNull?
    let publishedBy: Int
    let thumbnailLocation, id: String

    enum CodingKeys: String, CodingKey {
        case minorVersionNumber = "minor_version_number"
        case isMajorVersion = "is_major_version"
        case published
        case publishedTime = "published_time"
        case effectiveTime = "effective_time"
        case deprecatedTime = "deprecated_time"
        case body, protected, type
        case publishedVersionDynamic = "dynamic"
        case status
        case changeSummary = "change_summary"
        case notifySigners = "notify_signers"
        case tokens, title
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case account, site, contract
        case versionNumber = "version_number"
        case createdTime = "created_time"
        case updatedTime = "updated_time"
        case fields
        case downloadEndpoint = "download_endpoint"
        case editorVersion = "editor_version"
        case fullVersionNumber = "full_version_number"
        case majorVersion = "major_version"
        case publishedBy = "published_by"
        case thumbnailLocation = "thumbnail_location"
        case id
    }
}

// MARK: - Site
public struct Site: Codable {
    let features: [String: Bool?]
    let security: Security
    let emailAllowOverride, fileformatAllowOverride, verified: Bool
    let verifiedTime: JSONNull?
    let deleted, primary, sandbox, enforceLimits: Bool
    let locale, timeZone, adoptionLevel, mobileAcceptanceLanguage: String
    let approvalOrder: Bool
    let url: String
    let name: String
    let createdBy, updatedBy, account: Int
    let emailDisplayName, emailReplyAddress: String
    let companyInformation: CompanyInformation
    let createdTime, updatedTime, key: String
    public let acceptanceLanguage: String?
    let accessID: String
    let basePublishURL: String
    public let legalCenterURL: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case features, security
        case emailAllowOverride = "email_allow_override"
        case fileformatAllowOverride = "fileformat_allow_override"
        case verified
        case verifiedTime = "verified_time"
        case deleted, primary, sandbox
        case enforceLimits = "enforce_limits"
        case locale
        case timeZone = "time_zone"
        case adoptionLevel = "adoption_level"
        case mobileAcceptanceLanguage = "mobile_acceptance_language"
        case approvalOrder = "approval_order"
        case url, name
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case account
        case emailDisplayName = "email_display_name"
        case emailReplyAddress = "email_reply_address"
        case companyInformation = "company_information"
        case createdTime = "created_time"
        case updatedTime = "updated_time"
        case key
        case acceptanceLanguage = "acceptance_language"
        case accessID = "access_id"
        case basePublishURL = "base_publish_url"
        case legalCenterURL = "legal_center_url"
        case id
    }
}

// MARK: - CompanyInformation
public struct CompanyInformation: Codable {
    let phone, name, street, city: String
    let state, postalCode: String

    enum CodingKeys: String, CodingKey {
        case phone, name, street, city, state
        case postalCode = "postal_code"
    }
}

// MARK: - Security
public struct Security: Codable {
    let downloadURLTTL: Int

    enum CodingKeys: String, CodingKey {
        case downloadURLTTL = "download_url_ttl"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
