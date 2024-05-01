//
//  InteractionModel.swift
//  CineChoice
//
//  Created by Lucky on 26/04/24.
//

import Foundation

struct InteractionModel: Decodable {
    let interactionID: Int
    let userID: String
    let filmID: Int
    let action: String
    let shown: Bool
    
    let film: Film

    struct Film: Decodable {
        let filmID: Int
        let filmTitle: String
        let filmPoster: String
        let filmSoundtrack: String
    }
}
