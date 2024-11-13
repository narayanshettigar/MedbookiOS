//
//  Book.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import Foundation

// MARK: - Book Model
struct Book: Identifiable, Decodable {
    let id: String
    let title: String
    let authorName: [String]?
    let ratingsAverage: Double?
    let ratingsCount: Int?
    let coverId: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case authorName = "author_name"
        case ratingsAverage = "ratings_average"
        case ratingsCount = "ratings_count"
        case coverId = "cover_i"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        authorName = try container.decodeIfPresent([String].self, forKey: .authorName)
        ratingsAverage = try container.decodeIfPresent(Double.self, forKey: .ratingsAverage)
        ratingsCount = try container.decodeIfPresent(Int.self, forKey: .ratingsCount)
        coverId = try container.decodeIfPresent(Int.self, forKey: .coverId)
        id = UUID().uuidString
    }
}

struct BookResponse: Decodable {
    let numFound: Int
    let docs: [Book]
}
