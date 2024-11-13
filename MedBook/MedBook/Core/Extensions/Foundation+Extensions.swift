//
//  Foundation+Extensions.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftUI
import SwiftData
import UIKit

extension String {
    var isValidEmail: Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", AppConstants.Validation.emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

// MARK: - Debug Helper Extension
extension ModelContext {
    func printAllUsers() {
        do {
            let fetchRequest = FetchDescriptor<User>()
            let users = try fetch(fetchRequest)
            print("--- All Users in Database ---")
            for user in users {
                print("Email: \(user.email)")
            }
            print("---------------------------")
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}

extension UINavigationBar {
    static func changeAppearance(clear: Bool) {
        let appearance = UINavigationBarAppearance()
        
        if clear {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct ModelContainerKey: EnvironmentKey {
    static let defaultValue: ModelContainer? = nil
}

extension EnvironmentValues {
    var modelContainer: ModelContainer? {
        get { self[ModelContainerKey.self] }
        set { self[ModelContainerKey.self] = newValue }
    }
}
