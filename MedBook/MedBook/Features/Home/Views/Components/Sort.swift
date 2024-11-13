//
//  Sort.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//


import SwiftUI

// MARK: - Sort Options
enum SortOption: String, CaseIterable {
    case title = "Title"
    case rating = "Average Rating"
    case hits = "Hits"
}

struct SortButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected ?
                            LinearGradient(colors: [.black.opacity(0.8), .black.opacity(0.6)],
                                         startPoint: .leading,
                                         endPoint: .trailing) :
                                LinearGradient(colors: [.white],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                        )
                )
                .foregroundColor(isSelected ? .white : .black.opacity(0.7))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
