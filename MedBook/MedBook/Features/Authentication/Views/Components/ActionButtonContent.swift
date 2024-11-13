//
//  ActionButtonContent.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//
import SwiftUI

struct AuthButtonContent: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    var hasBorder: Bool = false
    
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: hasBorder ? 2 : 0)
            )
            .padding(.horizontal, 24)
    }
}
