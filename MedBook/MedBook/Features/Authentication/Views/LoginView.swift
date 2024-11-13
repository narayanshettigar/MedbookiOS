//
//  Login.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @Binding var isAuthenticated: Bool
    @State private var isPasswordVisible: Bool = false
    @Namespace private var animation
    
    init(isAuthenticated: Binding<Bool>, userRepository: UserRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(userRepository: userRepository))
        _isAuthenticated = isAuthenticated
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
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .padding(.top, 40)
                    
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold))
                            .matchedGeometryEffect(id: "title", in: animation)
                        
                        Text("Login in to continue")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Login Form
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
                                    .onChange(of: viewModel.email) { viewModel.validateForm() }
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
                                        TextField("Enter your password", text: $viewModel.password)
                                    } else {
                                        SecureField("Enter your password", text: $viewModel.password)
                                    }
                                }
                                .textContentType(.password)
                                .onChange(of: viewModel.password) { viewModel.validateForm() }
                                
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
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            if await viewModel.login() {
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
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            } else {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 56)
                        .padding(.horizontal)
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                            .font(.caption)
                            .bold()
                            .padding(4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.3), value: errorMessage)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .animation(.easeInOut, value: isPasswordVisible)
    }
}

class MockUserRepository: UserRepositoryProtocol {
    func createUser(email: String, password: String, country: String, countryCode: String) async throws -> User {
        return User(email: email, password: password, country: country, countryCode: countryCode)
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        return User(email: email, password: "password", country: "US", countryCode: "US")
    }
    
    func createSession(for userId: String) async throws {}
    
    func verifyCredentials(email: String, password: String) async throws -> Bool {
        // Simulate successful login only for specific credentials
        return email == "test@example.com" && password == "password123"
    }
}

#Preview {
    LoginView(
        isAuthenticated: .constant(false),
        userRepository: MockUserRepository()
    )
}
