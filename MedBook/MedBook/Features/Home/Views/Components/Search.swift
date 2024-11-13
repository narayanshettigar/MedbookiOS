//
//  Search.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftUI

// MARK: - Supporting Views
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black.opacity(0.8))
            
            TextField("Search for books...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black.opacity(0.8))
                }
            }
        }
        .padding(8)
        .background(.white.opacity(0.51))
        .cornerRadius(10)
    }
}
