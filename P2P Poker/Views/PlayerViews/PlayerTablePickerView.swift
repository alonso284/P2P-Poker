//
//  PlayerView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import SwiftUI

struct PlayerTablePickerView: View {
    @Binding var playerVM: PlayerViewModel
    
    var body: some View {
        if let player = playerVM.playerManager {
            List {
                if let table = player.table {
                    Text("Connected to \(table.displayName)")
                }
                ForEach(player.availableTables, id: \.self){
                    table in
                    // FIXME THIS BUTTON SHOULD OPEN THE NEW VIEW, IF CONNECTION UNSUCCESSFULL, RETURN
                    Button(table.displayName, action: {
                        player.join(table: table)
                    })
                    .disabled( player.table == table )
                }
            }
        }
    }
}
