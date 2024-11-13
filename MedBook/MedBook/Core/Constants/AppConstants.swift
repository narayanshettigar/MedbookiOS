//
//  AppConstants.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//

enum AppConstants {
    enum Validation {
        static let minimumPasswordLength = 8
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
    
    enum API {
        static let countriesBaseURL = "https://api.first.org/data/v1/countries"
        static let ipLookupURL = "http://ip-api.com/json"
        
        static func openLibrarySearchURL(searchText: String, itemsPerPage: Int, currentPage: Int) -> String {
            let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "https://openlibrary.org/search.json?title=\(encodedSearchText)&limit=\(itemsPerPage)&offset=\(currentPage * itemsPerPage)"
        }
    }
    
    enum UserDefaults {
        static let defaultCountryCodeKey = "DefaultCountryCode"
    }
    
    enum ImageURLs {
        static func coverImageURL(coverId: Int) -> String {
            return "https://covers.openlibrary.org/b/id/\(coverId)-M.jpg"
        }
    }
}
