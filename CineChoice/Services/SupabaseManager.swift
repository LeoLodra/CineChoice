//
//  SupabaseManager.swift
//  CineChoice
//
//  Created by Lucky on 30/04/24.
//

import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    
    static let shared = SupabaseManager()
    
    let supabaseClient = SupabaseConfiguration.supabaseClient
    
    @Published var user: UserModel?
    @Published var films: [FilmModel] = []
    @Published var cards: [CardModel] = []
    @Published var userInteractions: [InteractionModel] = []
    @Published var filmRatings: [FilmRatingModel] = []
    
    // Function to check if data has been fetched previously
    func shouldFetchData() -> Bool {
        return UserDefaults.standard.bool(forKey: "dataFetched")
    }
    
    // Function to mark data as fetched
    func markDataAsFetched() {
        UserDefaults.standard.set(true, forKey: "dataFetched")
    }
    
    func fetchInitialDataAndSubscribe(completion: @escaping (Error?) -> Void) {
        print("should ? = \(shouldFetchData())")
        if shouldFetchData() {
            Task {
                do {
                    
                    try await fetchInitialData()
                    
                    try await subscribeToRealtimeTable()
                    
                    markDataAsFetched()
                    
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func fetchInitialData() async throws {
        // Fetch user data
        let users = try await fetchUser(for: "1a4aa126000048f89c0e6d249f3249c2")

        // Fetch film data
        let films = try await fetchFilms(for: "1a4aa126000048f89c0e6d249f3249c2")
        
        // Fetch user interaction data
        let userInteractions = try await fetchUserInteractions(for: "1a4aa126000048f89c0e6d249f3249c2")
        
        // Fetch film and map inot card
        _ = try await fetchCards()
        
        // Fetch film dating data
        let filmRatings = try await fetchAllFilmRatings()
        
        DispatchQueue.main.async {
            self.user = users.first
            self.films = films
            self.userInteractions = userInteractions
            self.filmRatings = filmRatings
        }
    }
    
    func fetchUser(for userid: String) async throws -> [UserModel] {
        let response = try await supabaseClient.from("user").select().equals("userID", value: "1a4aa126000048f89c0e6d249f3249c2").execute()
        
        let data = response.data
        
        let decoder = JSONDecoder()
        
        do {
            let users = try decoder.decode([UserModel].self, from: data)
            
            return users
        } catch {
            throw error
        }
    }
    
    func fetchFilms(for userid: String) async throws -> [FilmModel] {
        
        let response = try await supabaseClient.rpc("getfilmsforuser", params: ["userid": userid]).order("filmID", ascending: true).execute()
        
        let data = response.data
        
        let decoder = JSONDecoder()
        
        do {
            let films = try decoder.decode([FilmModel].self, from: data)
            
            return films
        } catch {
            throw error
        }
    }
    
    func fetchCards() async throws -> [CardModel] {
        let filmData = try await SupabaseManager.shared.fetchFilms(for: "1a4aa126000048f89c0e6d249f3249c2")
        
        let mappedCardModels = filmData.map { film in
            return CardModel(film: film)
        }
        
        DispatchQueue.main.async {
            self.cards = mappedCardModels
        }

        return cards
    }
    
    func fetchUserInteractions(for userid: String) async throws -> [InteractionModel] {
        
        let response = try await supabaseClient.rpc("getinteractionwithfilm", params: ["interactionuserid": userid]).execute()
        
        let data = response.data
        
        if !data.isEmpty {
            
            let decoder = JSONDecoder()
            
            do {
                let interactions = try decoder.decode([InteractionModel].self, from: data)
                print(interactions)
                return interactions
            } catch {
                print("Error decoding user interactions:", error)
                
                throw error
            }
            
        } else {
            return []
        }
    }
    
    func fetchAllFilmRatings() async throws -> [FilmRatingModel] {
        let response = try await supabaseClient.rpc("getallfilmratings").execute()
        
        let data = response.data
        
        if !data.isEmpty {
            
            do {
                let filmRatings = try JSONDecoder().decode([[FilmRatingModel]].self, from: data)
                
                let flattenedRatings = filmRatings.flatMap { $0 }
                
                return flattenedRatings
            } catch {
                
                print("Error decoding film ratings:", error)
                
                throw error
            }
        } else {
            return []
        }
    }


    
    func subscribeToRealtimeTable() async throws {
        
        let channel = await supabaseClient.channel("channelId")

        let changeStream = await channel.postgresChange(AnyAction.self, schema: "public")

        await channel.subscribe()

        for await change in changeStream {
            switch change {
            case .delete(let action):
                if action.oldRecord.keys.contains("filmRatingID") {
                    try await updateFilmRatings()
                } else if action.oldRecord.keys.contains("interactionID") {
                    try await updateUserInteractions()
                }
            case .insert(let action):
                if action.record.keys.contains("filmRatingID") {
                    try await updateFilmRatings()
                } else if action.record.keys.contains("interactionID") {
                    try await updateUserInteractions()
                }
            case .select(let action):
                if action.record.keys.contains("filmRatingID") {
                    try await updateFilmRatings()
                } else if action.record.keys.contains("interactionID") {
                    try await updateUserInteractions()
                }
            case .update(let action):
                if action.record.keys.contains("filmRatingID") {
                    try await updateFilmRatings()
                } else if action.record.keys.contains("interactionID") {
                    try await updateUserInteractions()
                }
            }
        }
    }
    
    func updateFilmRatings() async throws {
        // Fetch the updated film ratings from the database
        let updatedFilmRatings = try await fetchAllFilmRatings()
        // Update the @Published var
        DispatchQueue.main.async {
            self.filmRatings = updatedFilmRatings
        }
    }
    
    func updateUserInteractions() async throws {
        // Fetch the updated film ratings from the database
        let updatedUserInteractions = try await fetchUserInteractions(for: "1a4aa126000048f89c0e6d249f3249c2")
        // Update the @Published var
        DispatchQueue.main.async {
            self.userInteractions = updatedUserInteractions
        }
    }
    
}
