//
//  UserRepositoryProtocol.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

// MARK: - UserRepository.swift
import SwiftData
import Foundation

protocol UserRepositoryProtocol {
    func createUser(email: String, password: String, country: String, countryCode: String) async throws -> User
    func findUserByEmail(_ email: String) async throws -> User?
    func createSession(for userId: String) async throws
    func verifyCredentials(email: String, password: String) async throws -> Bool
}

class UserRepository: UserRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createUser(email: String, password: String, country: String, countryCode: String) async throws -> User {
        let user = User(email: email, password: password, country: country, countryCode: countryCode)
        modelContext.insert(user)
        try modelContext.save()
        return user
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == email
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func createSession(for userId: String) async throws {
        let session = UserSession(userId: userId)
        modelContext.insert(session)
        try modelContext.save()
    }
    
    func verifyCredentials(email: String, password: String) async throws -> Bool {
        guard let user = try await findUserByEmail(email) else { return false }
        return user.password == password
    }
}
