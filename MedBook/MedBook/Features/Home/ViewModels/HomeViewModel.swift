//
//  HomeViewModel.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

import SwiftUI

// MARK: - HomeViewModel
@Observable
class HomeViewModel : ObservableObject{
    private let networkService: NetworkService
    private var currentPage = 0
    private let itemsPerPage = 10
    private var hasMoreResults = true
    
    var books: [Book] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?
    var selectedSortOption: SortOption = .title
    var showSortOptions = false
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    private var searchDebounceTask: Task<Void, Never>? = nil

    func searchBooks() async {
        guard searchText.count >= 3 else {
            books = []
            showSortOptions = false
            return
        }
        
        searchDebounceTask?.cancel()
        
        searchDebounceTask = Task {
            // Wait for 0.5 seconds before actually starting the network request
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
            
            await fetchSearchResults()
        }
    }

    private func fetchSearchResults() async {
        guard searchText.count >= 3 else {
            books = []
            showSortOptions = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let urlString = AppConstants.API.openLibrarySearchURL(searchText: searchText, itemsPerPage: itemsPerPage, currentPage: currentPage)
            
            let response: BookResponse = try await networkService.fetch(from: urlString)
            
            await MainActor.run {
                if currentPage == 0 {
                    books = response.docs
                } else {
                    books.append(contentsOf: response.docs)
                }
                
                hasMoreResults = response.docs.count == itemsPerPage
                showSortOptions = !books.isEmpty
                sortBooks()
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }

    func loadMoreIfNeeded(currentItem item: Book) {
        guard let itemIndex = books.firstIndex(where: { $0.id == item.id }),
              itemIndex >= books.count - 3,
              hasMoreResults,
              !isLoading else {
            return
        }
        
        currentPage += 1
        
        Task {
            isLoading = true
            await searchBooks()
        }
    }
    
    func sortBooks() {
        switch selectedSortOption {
        case .title:
            books.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .rating:
            books.sort { ($0.ratingsAverage ?? 0) > ($1.ratingsAverage ?? 0) }
        case .hits:
            books.sort { ($0.ratingsCount ?? 0) > ($1.ratingsCount ?? 0) }
        }
    }
    
    func resetSearch() {
        currentPage = 0
        books = []
        showSortOptions = false
        hasMoreResults = true
    }
}
