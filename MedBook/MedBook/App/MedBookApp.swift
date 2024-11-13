//
//  MedBookApp.swift
//  MedBook
//
//  Created by Narayan Shettigar on 09/11/24.
//

import SwiftUI
import SwiftData

@main
struct MedBookApp: App {
    let container: ModelContainer
    @State private var sessionManager: SessionManager!
    
    var body: some Scene {
        let userRepository = UserRepository(modelContext: container.mainContext)
        let countryRepository = CountryRepository(modelContext: container.mainContext)
        WindowGroup {
            Group {
                if sessionManager.isAuthenticated {
                    HomeScreen(sessionManager: sessionManager)
                } else {
                    NavigationStack {
                        LandingScreen(sessionManager: sessionManager, userRepository: userRepository, countryRepository: countryRepository)
                    }
                }
            }
            .environment(\.modelContainer, container)
            .onAppear {
                // Print the number of users for debugging
                #if DEBUG
                printDatabaseStats()
                #endif
            }
        }
    }
    
    init() {
        // Schema to include all models
        let schema = Schema([
            User.self,
            CountryData.self,
            UserSession.self
        ])
        
        let storeURL = URL.documentsDirectory.appendingPathComponent("MedBook.store")
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            _sessionManager = State(initialValue: SessionManager(modelContext: container.mainContext))
            
            print("Database location: \(storeURL.path)")
            
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
            
            if error.localizedDescription.contains("store file is corrupted") {
                try? FileManager.default.removeItem(at: storeURL)
                
                // Try creating a new store
                do {
                    container = try ModelContainer(
                        for: schema,
                        configurations: [modelConfiguration]
                    )
                    _sessionManager = State(initialValue: SessionManager(modelContext: container.mainContext))
                } catch {
                    fatalError("Could not recover from corrupted store: \(error)")
                }
            } else {
                do {
                    let fallbackConfiguration = ModelConfiguration(
                        schema: schema,
                        isStoredInMemoryOnly: true
                    )
                    
                    container = try ModelContainer(
                        for: schema,
                        configurations: [fallbackConfiguration]
                    )
                    _sessionManager = State(initialValue: SessionManager(modelContext: container.mainContext))
                    
                    print("WARNING: Using in-memory store due to error: \(error)")
                } catch {
                    fatalError("Could not initialize ModelContainer: \(error)")
                }
            }
        }
    }
    
    // Helper function to print database statistics
    private func printDatabaseStats() {
        do {
            let usersFetch = FetchDescriptor<User>()
            let sessionsFetch = FetchDescriptor<UserSession>()
            let countriesFetch = FetchDescriptor<CountryData>()
            
            let users = try container.mainContext.fetch(usersFetch)
            let sessions = try container.mainContext.fetch(sessionsFetch)
            let countries = try container.mainContext.fetch(countriesFetch)
            
            print("Database Statistics:")
            print("- Users: \(users.count)")
            print("- Active Sessions: \(sessions.filter { $0.isActive }.count)")
            print("- Countries: \(countries.count)")
        } catch {
            print("Failed to fetch database statistics: \(error)")
        }
    }
}
