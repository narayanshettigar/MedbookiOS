//
//  BookCard.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftUI

struct BookCard: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                VStack {
                    if let coverId = book.coverId {
                        AsyncImage(url: URL(string: AppConstants.ImageURLs.coverImageURL(coverId: coverId))) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 80, height: 80)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                
                            case .failure:
                                Image("defaultImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(8)
                            @unknown default:
                                Image("defaultImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(8)
                            }
                        }
                    } else {
                        Image("defaultImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(8)
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(.headline)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let authors = book.authorName, !authors.isEmpty {
                        Text(authors.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if let rating = book.ratingsAverage {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                            
                            if let count = book.ratingsCount {
                                Text("(\(count))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.subheadline)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
