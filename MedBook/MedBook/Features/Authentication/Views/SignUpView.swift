//
//  SignUp.swift
//  MedBook
//
//  Created by Narayan Shettigar on 09/11/24.
//

import SwiftUI
import SwiftData
import Foundation

struct SignupView: View {
    @ObservedObject var sessionManager: SessionManager
    @Environment(\.modelContainer) private var container: ModelContainer?
    @StateObject private var viewModel: SignupViewModel
    @Binding var isAuthenticated: Bool
    @State private var isPasswordVisible: Bool = false
    @Namespace private var animation
    @StateObject private var countryRepository: CountryRepository
    
    init(modelContext: ModelContext, sessionManager: SessionManager, isAuthenticated: Binding<Bool>, userRepository: UserRepositoryProtocol, countryRepository: CountryRepositoryProtocol) {
        UINavigationBar.changeAppearance(clear: true)
        _viewModel = StateObject(wrappedValue: SignupViewModel(userRepository: userRepository, countryRepository: countryRepository))
        self.sessionManager = sessionManager
        _isAuthenticated = isAuthenticated
        _countryRepository = StateObject(wrappedValue: countryRepository as! CountryRepository)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Logo and welcome text
                    HStack(alignment: .top) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold))
                                .matchedGeometryEffect(id: "title", in: animation)
                            
                            Text("Sign up to get started")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                    .padding(.top, 20)
                    
                    // Signup Form
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.7))
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                
                                TextField("Enter your email", text: $viewModel.email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .onChange(of: viewModel.email) { viewModel.validateEmail() }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.7))
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                
                                Group {
                                    if isPasswordVisible {
                                        TextField("Create password", text: $viewModel.password)
                                    } else {
                                        SecureField("Create password", text: $viewModel.password)
                                    }
                                }
                                .textContentType(.newPassword)
                                .onChange(of: viewModel.password) { viewModel.validatePassword() }
                                
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        if !viewModel.password.isEmpty {
                            PasswordCheckView(checks: viewModel.passwordChecks)
                        }
                        
                        // Country Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Country")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.7))
                            
                            if container != nil {
                                CountryPickerView(selectedCountry: $viewModel.selectedCountry, countryRepository: countryRepository)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    .frame(height: 150)
                            } else {
                                Text("Error: Model container is unavailable")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Button
                    Button(action: {
                        Task {
                            if await viewModel.signup() {
                                withAnimation(.spring()) {
                                    isAuthenticated = true
                                }
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.isValid ?
                                      LinearGradient(colors: [.black.opacity(0.8)],
                                                     startPoint: .leading,
                                                     endPoint: .trailing) :
                                        LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.5)],
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(height: 56)
                        .padding(.horizontal)
                    }
                    .disabled(!viewModel.isValid)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .environment(\.modelContext, container!.mainContext)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .animation(.easeInOut, value: isPasswordVisible)
    }
}

// MARK: - Supporting Views
struct PasswordCheckView: View {
    let checks: PasswordValidation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            PasswordCheckRow(
                title: "Minimum 8 characters",
                isValid: checks.hasMinLength
            )
            PasswordCheckRow(
                title: "At least 1 number",
                isValid: checks.hasNumber
            )
            PasswordCheckRow(
                title: "At least 1 uppercase letter",
                isValid: checks.hasUppercase
            )
            PasswordCheckRow(
                title: "At least 1 special character",
                isValid: checks.hasSpecialCharacter
            )
        }
    }
}

#Preview(body: {
    PasswordCheckView(checks: PasswordValidation(hasMinLength: true))
})

struct PasswordCheckRow: View {
    let title: String
    let isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .red.opacity(0.6))

            Text(title)
                .font(.caption)
                .foregroundColor(isValid ? .black : .black.opacity(0.6))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
        }
        .animation(.easeInOut, value: isValid)
    }
}

struct CountryPickerView: View {
    @Binding var selectedCountry: CountryData?
    @State private var countries: [CountryData] = []
    @State private var isLoading = true
    @ObservedObject var countryRepository: CountryRepository
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading countries...")
                    .padding()
            } else {
                Picker("Select Country", selection: $selectedCountry) {
                    Text("Select a country")
                        .tag(Optional<CountryData>.none)
                    
                    ForEach(countries) { country in
                        Text(country.name)
                            .tag(Optional(country))
                    }
                }
                .pickerStyle(.wheel)
            }
        }
        .onAppear {
            Task {
                await loadCountries()
            }
        }
    }
    
    private func loadCountries() async {
        do {
            if try await countryRepository.hasStoredCountries() {
                countries = try await countryRepository.getAllCountries()
            } else {
                countries = try await countryRepository.fetchCountriesFromAPI()
                try await countryRepository.saveCountries(countries)
            }
            isLoading = false
        } catch {
            print("Failed to load countries: \(error)")
            isLoading = false
        }
    }
}
