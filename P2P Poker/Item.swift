//
//  Item.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
