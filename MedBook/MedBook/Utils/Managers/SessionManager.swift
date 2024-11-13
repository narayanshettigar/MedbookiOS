//
//  SessionManager.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import Foundation
import SwiftData

// MARK: - Session Manager
@Observable
class SessionManager : ObservableObject{
    var isAuthenticated = false
    var errorMessage: String?
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        checkSession()
    }
    
    func checkSession() {
        do {
            let fetchRequest = FetchDescriptor<UserSession>(
                predicate: #Predicate<UserSession> { session in
                    session.isActive == true
                }
            )
            
            let sessions = try modelContext.fetch(fetchRequest)
            isAuthenticated = !sessions.isEmpty
        } catch {
            print("Failed to check session: \(error)")
            errorMessage = "Failed to check session: \(error.localizedDescription)"
            isAuthenticated = false
        }
    }
    
    func logout() {
        do {
            let fetchRequest = FetchDescriptor<UserSession>(
                predicate: #Predicate<UserSession> { session in
                    session.isActive == true
                }
            )
            
            let sessions = try modelContext.fetch(fetchRequest)
            sessions.forEach { session in
                session.isActive = false
            }
            
            try modelContext.save()
            isAuthenticated = false
        } catch {
            print("Failed to logout: \(error)")
            errorMessage = "Failed to logout: \(error.localizedDescription)"
        }
    }
}
