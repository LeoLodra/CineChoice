//
//  CardViewModel.swift
//  CineChoice
//
//  Created by Lucky on 27/04/24.
//

import Foundation
import SwiftUI

class CardViewModel: ObservableObject {
    
//    @Published var cardModels = [CardModel]()
//    
//    private let service: CardService
//    
//    init(service: CardService) {
//        self.service = service
//        Task { await fetchCardModels() } 
//    }
//    
//    func fetchCardModels() async {
//        do {
//            self.cardModels = try await service.fetchCardModels()
//        } catch {
//            print(error)
//        }
//    }
    
    //@State private var cardModels: [CardModel] = []
    @Published var cardModels = [CardModel]()
    
    func fetchCardModels() {
        CloudKitManager.shared.fetchFilms { [weak self] (filmModels, error) in
            guard let self = self else { return }
                        
            if let error = error {
                print("Error fetching FilmModels: \(error)")
                return
            }
            
            guard let filmModels = filmModels else {
                print("No Film fetched")
                return
            }
            
            // Create CardModel instances using fetched FilmModel instances
            let cardModels = filmModels.map { filmModel -> CardModel in
                return CardModel(film: filmModel)
            }
            
            // Update cardModels property
            DispatchQueue.main.async {
                self.cardModels = cardModels
            }
            
//            print(cardModels)
        }
    }
    
    func removeCard(_ card: CardModel, index: Int) {
        guard let removeIndex = cardModels.firstIndex(where: { $0.id == card.id }) else { return }
        
        cardModels.remove(at: removeIndex)
    }
}
