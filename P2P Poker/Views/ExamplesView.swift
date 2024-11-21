//
//  ExamplesView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 20/11/24.
//

import SwiftUI

struct ExamplesView: View {

    
    let hands: [(name: String, cards: [Card])] = [
        (name: "Straight flush", cards: [
            Card(suit: .clubs, rank: .jack),
            Card(suit: .clubs, rank: .ten),
            Card(suit: .clubs, rank: .nine),
            Card(suit: .clubs, rank: .eight),
            Card(suit: .clubs, rank: .seven),
        ]),
        (name: "Four of a kind", cards: [
            Card(suit: .clubs, rank: .five),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .hearts, rank: .five),
            Card(suit: .spades, rank: .five),
            Card(suit: .diamonds, rank: .two),
        ]),
        (name: "Full House", cards: [
            Card(suit: .spades, rank: .six),
            Card(suit: .hearts, rank: .six),
            Card(suit: .diamonds, rank: .six),
            Card(suit: .clubs, rank: .king),
            Card(suit: .hearts, rank: .king),
        ]),
        (name: "Flush", cards: [
            Card(suit: .diamonds, rank: .jack),
            Card(suit: .diamonds, rank: .nine),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .diamonds, rank: .three),
        ]),
        (name: "Straight", cards: [
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .spades, rank: .nine),
            Card(suit: .hearts, rank: .eight),
            Card(suit: .diamonds, rank: .seven),
            Card(suit: .clubs, rank: .six),
        ]),
        (name: "Three of a Kind", cards: [
            Card(suit: .clubs, rank: .queen),
            Card(suit: .spades, rank: .queen),
            Card(suit: .hearts, rank: .queen),
            Card(suit: .hearts, rank: .nine),
            Card(suit: .spades, rank: .two),
        ]),
        (name: "Two Pair", cards: [
            Card(suit: .hearts, rank: .jack),
            Card(suit: .spades, rank: .jack),
            Card(suit: .clubs, rank: .three),
            Card(suit: .spades, rank: .three),
            Card(suit: .hearts, rank: .two),
        ]),
        (name: "One pair", cards: [
            Card(suit: .spades, rank: .ten),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .spades, rank: .eight),
            Card(suit: .hearts, rank: .seven),
            Card(suit: .clubs, rank: .four),
        ]),
        (name: "High Card", cards: [
            Card(suit: .diamonds, rank: .king),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .spades, rank: .seven),
            Card(suit: .spades, rank: .four),
            Card(suit: .hearts, rank: .three),
        ]),
    ]
    var body: some View {
        NavigationStack {
            List {
                ForEach(hands, id: \.name){
                    (name, cards) in
                    Section(name){
                        HStack {
                            Spacer()
                            ForEach(cards){
                                card in
                                CardView(card: card)
                                    .font(.title2)
                                Spacer()
                            }
                        }
                    }
                    
                }
            }
            .navigationTitle("Poker Hands")
        }
    }
}

#Preview {
    ExamplesView()
}
