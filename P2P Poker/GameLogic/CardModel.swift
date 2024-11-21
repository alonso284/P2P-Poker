//
//  CardModel.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 16/11/24.
//

import Foundation
import SwiftUI

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
        
        var rankValue: Int {
            switch self {
            case .two:        return 2
            case .three:      return 3
            case .four:       return 4
            case .five:       return 5
            case .six:        return 6
            case .seven:      return 7
            case .eight:      return 8
            case .nine:       return 9
            case .ten:        return 10
            case .jack:       return 11
            case .queen:      return 12
            case .king:       return 13
            case .ace:        return 14
            }
        }
    }
    
    var id: String {
        return "\(rank.rawValue)_of_\((suit.rawValue))"
    }
//    static func < (lhs: Card, rhs: Card) -> Bool {
//        if(lhs.suit == rhs.suit){
//            return lhs.rank.rankValue() < rhs.rank.rankValue()
//        }
//        return lhs.suit.rawValue < rhs.suit.rawValue
//    }

    let suit: Suit
    let rank: Rank
}

func freshDeck() -> [Card] {
    var deck: [Card] = []
    for suit in Card.Suit.allCases {
        for rank in Card.Rank.allCases {
            deck.append(Card(suit: suit, rank: rank))
        }
    }
    deck.shuffle()
    return deck
}

enum Hand: Comparable, Encodable {
    case high           (Int)
    case onePair        (Int)
    case twoPair        (Int, Int)
    case threeOfAKind   (Int)
    case straight       (Int)
    case flush          (Int)
    case fullHouse      (Int, Int)
    case fourOfAKind    (Int)
    case straightFlush  (Int)
    
    func tuple() -> (Int, Int, Int) {
        switch self {
        case .high(let highest):
            return (0, highest, 0)
        case .onePair(let pair):
            return (1, pair, 0)
        case .twoPair(let firstHighestPair, let secondHighestPair):
            return (2, firstHighestPair, secondHighestPair)
        case .threeOfAKind(let kind):
            return (3, kind, 0)
        case .straight(let highest):
            return (4, highest, 0)
        case .flush(let highest):
            return (5, highest, 0)
        case .fullHouse(let triplet, let pair):
            return (6, triplet, pair)
        case .fourOfAKind(let kind):
            return (7, kind, 0)
        case .straightFlush(let highest):
            return (8, highest, 0)
        }
    }
    
    static func < (lhs: Hand, rhs: Hand) -> Bool {
        return lhs.tuple() < rhs.tuple()
    }
    
    // cards is an arrary with unique cards
    init?(cards: [Card]) {
        if cards.isEmpty { return nil }
        
        // Rank Histograms
        func histogram(_ cards: [Card]) -> [Int: Int] {
            var histogram: [Int: Int] = [:]
            for card in cards {
                histogram[card.rank.rankValue, default: 0] += 1
            }
            return histogram
        }
        // Straigh Flush
        func straightFlush(_ cards: [Card]) -> Hand? {
            var highest: Int? = nil
            for suit in Card.Suit.allCases {
                let cardsBySuit:[Card] = cards.filter({ $0.suit == suit })
                if let straight = straight(cardsBySuit), case let Hand.straight( highestBySuit) = straight {
                    highest = highestBySuit
                }
            }
            if let highest {
                return .straightFlush(highest)
            }
            return nil
        }
        // Four of a Kind
        func fourOfAKind(_ cards: [Card]) -> Hand? {
            var histogram = histogram(cards)
            histogram = histogram.filter({ $0.value >= 4 })
            let highestPair: Int? = histogram.max(by: { $0.key < $1.key })?.key
            if let highestPair { return .fourOfAKind(highestPair) }
            return nil
        }
        // Full House
        func fullHouse(_ cards: [Card]) -> Hand? {
            let histogram = histogram(cards)
            let triplets = histogram.filter({ $0.value >= 3 }).keys.sorted(by: >)
            let pairs = histogram.filter({ $0.value >= 2 }).keys.sorted(by: >)
            for triplet in triplets {
                for pair in pairs {
                    if triplet != pair {
                        return .fullHouse(triplet, pair)
                    }
                }
            }
            return nil
        }
        // Flush
        func flush(_ cards: [Card]) -> Hand? {
            var highest: Int? = nil
            for suit in Card.Suit.allCases {
                let cardsBySuit:[Card] = cards.filter({ $0.suit == suit })
                if  !cardsBySuit.isEmpty, cardsBySuit.count >= 5, let highestCardRank = cardsBySuit.max(by: { $0.rank.rankValue < $1.rank.rankValue })?.rank.rankValue {
                    highest = highestCardRank
                }
            }
            if let highest {
                return .flush(highest)
            }
            return nil
        }
        // Straight
        func straight(_ cards: [Card]) -> Hand? {
            let histogram = histogram(cards)
            var uniqueCard: [Int] = histogram.keys.sorted(by: >)
            if(uniqueCard.contains(14)){
                uniqueCard.append(1)
            }
            if(uniqueCard.count < 5){ return nil }
            var streak = 1;
            for indx in 1..<uniqueCard.count {
                if(uniqueCard[indx-1]-1 == uniqueCard[indx]){
                    streak += 1
                } else {
                    streak = 1
                }
                if(streak == 5){
                    return .straight(uniqueCard[indx]+4)
                }
            }
            return nil
        }
        // Three of a Kind
        func threeOfAKind(_ cards: [Card]) -> Hand? {
            var histogram = histogram(cards)
            histogram = histogram.filter({ $0.value >= 3 })
            let highestPair: Int? = histogram.max(by: { $0.key < $1.key })?.key
            if let highestPair { return .threeOfAKind(highestPair) }
            return nil
        }
        // Two Pair
        func twoPair(_ cards: [Card]) -> Hand? {
            var histogram = histogram(cards)
            histogram = histogram.filter({ $0.value >= 2 })
            
            let firstHighestPair: Int? = histogram.max(by: { $0.key < $1.key })?.key
            guard let firstHighestPair else { return nil }
            
            histogram.removeValue(forKey: firstHighestPair)
            
            let secondHighestPair: Int? = histogram.max(by: { $0.key < $1.key })?.key
            guard let secondHighestPair else { return nil }
            
            return .twoPair(firstHighestPair, secondHighestPair)
        }
        // One Pair
        func onePair(_ cards: [Card]) -> Hand? {
            var histogram = histogram(cards)
            histogram = histogram.filter({ $0.value >= 2 })
            let highestPair: Int? = histogram.max(by: { $0.key < $1.key })?.key
            if let highestPair { return .onePair(highestPair) }
            return nil
        }
        // High Card
        func high(_ cards: [Card]) -> Hand? {
            let highCard: Int? = cards.max(by: { $0.rank.rankValue < $1.rank.rankValue })?.rank.rankValue
            if let highCard { return .high(highCard) }
            return nil
        }
        
        self = high(cards)!
        if let onePair = onePair(cards) { self = onePair }
        if let twoPair = twoPair(cards) { self = twoPair }
        if let threeOfAKind = threeOfAKind(cards) { self = threeOfAKind }
        if let straight = straight(cards) { self = straight }
        if let flush = flush(cards) { self = flush }
        if let fullHouse = fullHouse(cards) { self = fullHouse }
        if let fourOfAKind = fourOfAKind(cards) { self = fourOfAKind }
        if let straightFlush = straightFlush(cards) { self = straightFlush }
        
    }
}
