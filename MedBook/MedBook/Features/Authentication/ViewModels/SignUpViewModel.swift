//
//  SignUpViewModel.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftData
import SwiftUI

// MARK: - ViewModel
@Observable
class SignupViewModel : ObservableObject {
    // User inputs
    var email = ""
    var password = ""
    var selectedCountry: CountryData?
    
    // State
    var isLoading = false
    var errorMessage: String?
    var isValid = false
    
    // Validation states
    var isEmailValid = false
    var isPasswordValid = false
    var passwordChecks = PasswordValidation()
    
    private let userRepository: UserRepositoryProtocol
    private let countryRepository: CountryRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol, countryRepository: CountryRepositoryProtocol) {
        self.userRepository = userRepository
        self.countryRepository = countryRepository
        loadDefaultCountry()
    }
    
    // MARK: - Validation Methods
    func validateEmail() {
        isEmailValid = email.isValidEmail
        updateFormValidation()
    }
    
    func validatePassword() {
        passwordChecks.hasMinLength = password.count >= 8
        passwordChecks.hasNumber = password.range(of: ".*[0-9]+.*", options: .regularExpression) != nil
        passwordChecks.hasUppercase = password.range(of: ".*[A-Z]+.*", options: .regularExpression) != nil
        passwordChecks.hasSpecialCharacter = password.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        
        isPasswordValid = passwordChecks.isValid
        updateFormValidation()
    }
    
    private func updateFormValidation() {
        isValid = isEmailValid && isPasswordValid && selectedCountry != nil
    }
    
    private func loadDefaultCountry() {
        if let savedCountryCode = UserDefaults.standard.string(forKey: AppConstants.UserDefaults.defaultCountryCodeKey) {
            loadSavedCountry(code: savedCountryCode)
        } else {
            Task {
                do {
                    let defaultCountry = try await countryRepository.fetchDefaultCountry()
                    await MainActor.run {
                        UserDefaults.standard.set(defaultCountry.code, forKey: AppConstants.UserDefaults.defaultCountryCodeKey)
                        loadSavedCountry(code: defaultCountry.code)
                        print(defaultCountry.code)
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to fetch default country"
                    }
                }
            }
        }
    }
    
    private func loadSavedCountry(code: String) {
        Task {
            do {
                let allCountries = try await countryRepository.getAllCountries()
                
                // Find the country with the matching code
                if let country = allCountries.first(where: { $0.code == code }) {
                    await MainActor.run {
                        // Update the selected country on the main thread
                        selectedCountry = country
                    }
                } 
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load saved country: \(error.localizedDescription)"
                }
            }
        }
    }

    
    // MARK: - Signup Method
    func signup() async -> Bool {
        guard isValid else { return false }
        
        do {
            // Check if user exists
            if let _ = try await userRepository.findUserByEmail(email) {
                await MainActor.run {
                    errorMessage = "An account with this email already exists"
                }
                return false
            }
            
            // Create new user
            let user = try await userRepository.createUser(
                email: email,
                password: password,
                country: selectedCountry?.name ?? "",
                countryCode: selectedCountry?.code ?? ""
            )
            
            // Create session
            try await userRepository.createSession(for: user.email)
            
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Failed to create account: \(error.localizedDescription)"
            }
            return false
        }
    }
}

// MARK: - Password Validation Helper
struct PasswordValidation {
    var hasMinLength = false
    var hasUppercase = false
    var hasNumber = false
    var hasSpecialCharacter = false
    
    var isValid: Bool {
        hasMinLength && hasUppercase && hasNumber && hasSpecialCharacter
    }
}
