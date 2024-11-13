//
//  CountryData.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftData

@Model
class CountryData {
    var name: String
    var code: String
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}

// MARK: - API Models
struct CountryResponse: Codable {
    let status: String
    let statusCode: Int
    let version: String
    let access: String
    let total: Int
    let offset: Int
    let limit: Int
    let data: [String: CountryDetail]

    enum CodingKeys: String, CodingKey {
        case status
        case statusCode = "status-code"
        case version
        case access
        case total
        case offset
        case limit
        case data
    }
}

struct CountryDetail: Codable {
    let country: String
    let region: String
}

struct IPResponse: Codable {
    let countryCode: String
    let country: String
}
