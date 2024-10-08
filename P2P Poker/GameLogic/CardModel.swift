//
//  CardModel.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import Foundation
import SwiftUI

struct TableAction : Codable {
    enum Action: Codable {
        case turn(Int)
        case beginround(Card, Card), endround(Int)
        case begingame(Int), endgame(Bool)
//        case error, success
    }
    
    var action: Action
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct PlayerAction: Codable {
    enum Action: Codable {
        case play(Int), status(Bool), exit
    }
    var action: Action
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct Card: Codable, Identifiable {
    enum Suit: String, Codable, CaseIterable {
        case hearts     = "heart"
        case diamonds   = "diamond"
        case clubs      = "club"
        case spades     = "spade"
        
        func color() -> Color {
            switch self {
            case .spades:   return .black
            case .hearts:   return .red
            case .diamonds: return .red
            case .clubs:    return .black
            }
        }
    }

    enum Rank: String, Codable, CaseIterable {
        case two        = "2"
        case three      = "3"
        case four       = "4"
        case five       = "5"
        case six        = "6"
        case seven      = "7"
        case eight      = "8"
        case nine       = "9"
        case ten        = "10"
        case jack       = "J"
        case queen      = "Q"
        case king       = "K"
        case ace        = "A"
    }
    
    var id: String {
        return "\(rank.rawValue)_of_\((suit.rawValue))"
    }

    let suit: Suit
    let rank: Rank
}
