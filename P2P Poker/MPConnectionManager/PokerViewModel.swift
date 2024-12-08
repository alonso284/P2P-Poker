//
//  PokerViewModel.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 21/11/24.
//

import Foundation

@Observable
final class TableViewModel {
    var tableManager: TableManager?
    
    func initialize(name: String){
        if name.isEmpty { return }
        self.tableManager = TableManager(name: name)
    }
    
    func deinitialize() {
        self.tableManager = nil
    }
}

@Observable
final class PlayerViewModel {
    var playerManager: PlayerManager?
    
    func initialize(user: String, avatar: String){
        if user.isEmpty { return }
        self.playerManager = PlayerManager(user: user, avatar: avatar)
    }
    
    func deinitialize() {
        self.playerManager = nil
    }
}
