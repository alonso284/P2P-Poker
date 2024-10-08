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
        VStack {
            Spacer()
            Label("\(card.rank.rawValue)", systemImage: "suit.\(card.suit.rawValue).fill")
                .foregroundStyle(card.suit.color())
                .font(.largeTitle)
            Spacer()
        }
    }
    
}

#Preview {
    CardView(card: Card(suit: .diamonds, rank: .ace))
    CardView(card: Card(suit: .spades, rank: .two))
}
