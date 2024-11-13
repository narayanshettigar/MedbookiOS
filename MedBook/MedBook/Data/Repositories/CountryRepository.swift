//
//  CountryRepositoryProtocol.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//


// MARK: - CountryRepository.swift
import SwiftData
import Foundation

protocol CountryRepositoryProtocol {
    func getAllCountries() async throws -> [CountryData]
    func saveCountries(_ countries: [CountryData]) async throws
    func hasStoredCountries() async throws -> Bool
    func fetchCountriesFromAPI() async throws -> [CountryData]
    func fetchDefaultCountry() async throws -> (code: String, name: String)
}

@Observable
class CountryRepository: CountryRepositoryProtocol, ObservableObject {
    private let modelContext: ModelContext
    private let networkService: NetworkService
    
    init(modelContext: ModelContext, networkService: NetworkService = .shared) {
        self.modelContext = modelContext
        self.networkService = networkService
    }
    
    func getAllCountries() async throws -> [CountryData] {
        let descriptor = FetchDescriptor<CountryData>(sortBy: [SortDescriptor(\CountryData.name)])
        return try modelContext.fetch(descriptor)
    }
    
    func saveCountries(_ countries: [CountryData]) async throws {
        for country in countries {
            modelContext.insert(country)
        }
        try modelContext.save()
    }
    
    func hasStoredCountries() async throws -> Bool {
        do {
            let descriptor = FetchDescriptor<CountryData>()
            let countries = try modelContext.fetch(descriptor)
            
            return !countries.isEmpty
        } catch {
            print("Error fetching countries: \(error)")
            throw error
        }
    }
    
    func fetchCountriesFromAPI() async throws -> [CountryData] {
        let response: CountryResponse = try await networkService.fetch(from: AppConstants.API.countriesBaseURL)
        return response.data.map { code, detail in
            CountryData(name: detail.country, code: code)
        }
    }
    
    func fetchDefaultCountry() async throws -> (code: String, name: String) {
        let response: IPResponse = try await networkService.fetch(from: AppConstants.API.ipLookupURL)
        return (response.countryCode, response.country)
    }
}
