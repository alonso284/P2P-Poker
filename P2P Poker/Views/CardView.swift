//
//  CardView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 26/09/24.
//

import SwiftUI

struct CardView: View {
    var card: Card
    
    var body: some View {
//        Label("\(card.rank.rawValue)", systemImage: "suit.\(card.suit.rawValue).fill")
//            .foregroundStyle(card.suit.color())
        HStack(spacing: 2) {
            Image(systemName: "suit.\(card.suit.rawValue).fill")
            Text("\(card.rank.rawValue)")
        }
        .foregroundStyle(card.suit.color())
    }
    
}

#Preview {
    CardView(card: Card(suit: .diamonds, rank: .ace))
        .font(.title)
    CardView(card: Card(suit: .spades, rank: .two))
}
