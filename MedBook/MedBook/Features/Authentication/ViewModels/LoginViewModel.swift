//
//  LoginViewModel.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isValid = false

    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func validateForm() {
        isValid = !email.isEmpty && !password.isEmpty
    }
    
    func login() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // Validate the form before proceeding
        validateForm()
        
        guard isValid else {
            errorMessage = "Please enter both email and password."
            return false
        }
        
        do {
            guard let user = try await userRepository.findUserByEmail(email) else {
                errorMessage = "No account found with this email."
                return false
            }
            
            let isValidCredentials = try await userRepository.verifyCredentials(email: email, password: password)
            
            if !isValidCredentials {
                errorMessage = "Invalid password."
                return false
            }
            
            // Create a session for the user
            try await userRepository.createSession(for: user.email)
            
            // Successfully logged in
            return true
            
        } catch {
            print("Login failed: \(error)")
            errorMessage = "Login failed: \(error.localizedDescription)"
            return false
        }
    }
}
