//
//  UserSession.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftData
import Foundation

@Model
class UserSession {
    var userId: String
    var isActive: Bool
    var lastLoginDate: Date
    
    init(userId: String) {
        self.userId = userId
        self.isActive = true
        self.lastLoginDate = Date()
    }
}
