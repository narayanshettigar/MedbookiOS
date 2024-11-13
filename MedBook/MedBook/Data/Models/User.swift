//
//  User.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//
import SwiftData
import Foundation

@Model
class User {
    var email: String
    var password: String
    var country: String
    var countryCode: String
    var createdAt: Date
    
    init(email: String, password: String, country: String, countryCode: String) {
        self.email = email.lowercased()
        self.password = password
        self.country = country
        self.countryCode = countryCode
        self.createdAt = Date()
    }
    
    func verifyPassword(_ password: String) -> Bool {
        guard !self.password.isEmpty else {
            print("Warning: User has empty password")
            return false
        }
        return self.password == password
    }
}
