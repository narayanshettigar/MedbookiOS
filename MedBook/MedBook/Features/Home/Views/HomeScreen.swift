//
//  HomeScreen.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftUI

// MARK: - HomeScreen
@MainActor
struct HomeScreen: View {
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject var sessionManager: SessionManager
    
    init(sessionManager: SessionManager) {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
        self.sessionManager = sessionManager
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        HStack {
                            Image("home-title-logo")
                                .resizable()
                                .frame(width: 54, height: 54)
                            Text("MedBook")
                                .font(.system(size: 32, weight: .bold))
                        }
                        
                        
                        Spacer()
                        
                        Button(action: {
                            sessionManager.logout()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right") // Logout icon
                                .imageScale(.large)
                                .foregroundStyle(.black)
                                .bold()
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.4))
                    )
                    .shadow(radius: 5)
                    .padding()

                    HStack {
                        Text("What topics would you like to explore today?")
                            .font(.system(size: 24, weight: .semibold))
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding()
                    
                    if viewModel.showSortOptions {
                        // Sort Options
                        HStack {
                            Text("Sort By:")
                                .bold()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        SortButton(
                                            title: option.rawValue,
                                            isSelected: viewModel.selectedSortOption == option
                                        ) {
                                            viewModel.selectedSortOption = option
                                            viewModel.sortBooks()
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    
                    // Book List
                    List(viewModel.books) { book in
                        Section {
                            BookCard(book: book)
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(currentItem: book)
                                }
                                .listRowBackground(
                                    Rectangle()
                                        .fill(Color.clear)
                                        .padding(0)
                                )
                                .listRowSeparator(.hidden)
                        } header: {
                            Spacer(minLength: 0).listRowInsets(EdgeInsets())
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .environment(\.defaultMinListHeaderHeight, 0)
                    .scrollContentBackground(.hidden)
                    
                    if viewModel.isLoading && !viewModel.books.isEmpty {
                        ProgressView()
                            .padding()
                            .frame(alignment: .center)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.isLoading && viewModel.books.isEmpty {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onChange(of: viewModel.searchText) {
            guard viewModel.searchText.count >= 3 else {
                viewModel.resetSearch()
                return
            }
            
            Task {
                await viewModel.searchBooks()
            }
        }
    }
}
