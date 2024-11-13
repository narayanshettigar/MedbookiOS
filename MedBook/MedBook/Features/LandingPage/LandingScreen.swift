//
//  ContentView.swift
//  MedBook
//
//  Created by Narayan Shettigar on 09/11/24.
//

import SwiftUI
import SwiftData

struct LandingScreen: View {
    @State private var isAnimating = false
    @State private var navigationPath = NavigationPath()
    @Environment(\.modelContainer) private var container: ModelContainer?
    @ObservedObject var sessionManager: SessionManager
    let userRepository: UserRepositoryProtocol
    let countryRepository : CountryRepositoryProtocol
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("landing-page-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 300)
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1 : 0)
                    
                    // Welcome text
                    Text("MedBook")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    Text("Start your journey with us")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        if let container = container {
                            NavigationLink(destination: {
                                SignupView(modelContext: container.mainContext, sessionManager: sessionManager, isAuthenticated: $sessionManager.isAuthenticated, userRepository: userRepository, countryRepository: countryRepository)
                            }, label: {
                                AuthButtonContent(
                                    title: "Sign Up",
                                    backgroundColor: .white,
                                    textColor: .black
                                )
                            })
                            
                            NavigationLink(destination: {
                                LoginView(
                                    isAuthenticated: $sessionManager.isAuthenticated, userRepository: userRepository
                                )
                            }, label: {
                                AuthButtonContent(
                                    title: "Login",
                                    backgroundColor: .clear,
                                    textColor: .white,
                                    hasBorder: true
                                )
                            })
                        } else {
                            Text("Error: Model container is unavailable")
                        }
                    }
                    .padding(.bottom, 50)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            isAnimating = false
            
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}


#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, UserSession.self, CountryData.self, configurations: config)
        
        // Create mock dependencies
        let modelContext = container.mainContext
        let sessionManager = SessionManager(modelContext: modelContext)
        let userRepository = UserRepository(modelContext: modelContext)
        let countryRepository = CountryRepository(modelContext: modelContext, networkService: .shared)
        
        return LandingScreen(
            sessionManager: sessionManager,
            userRepository: userRepository,
            countryRepository: countryRepository
        )
        .modelContainer(container)
        
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
