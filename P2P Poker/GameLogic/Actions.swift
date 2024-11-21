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
        /// Indicates it is the player's turn, along with the amount they need to match with their bet
        case turn(Int)
        /// Indiacates a round has begun, along with the player's hand
        case beginround(Card, Card)
        /// Indicates the end of a round, along with the amount of money the player won
        case endround(Int)
        /// Inidcates the game has begun, along with the players initial amount
        case begingame(Int)
        /// Indicates the game ended, along with their final standing
        case endgame(UInt)
        // FIXME: Error handling
//        case error, success
        case newBalance(Int)
        case ping
    }
    
    var action: Action
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct PlayerAction: Codable {
    enum Action: Codable {
        /// Indicates the amount played in a turn
        case play(Int)
        /// Indicates a player with sit-out for the next round
        case status
        // FIXME: Remove
        case ping
    }
    var action: Action
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
