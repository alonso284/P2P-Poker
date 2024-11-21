//
//  PlayerView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import SwiftUI

struct PlayerTablePickerView: View {
    @State var player: PlayerManager
    
    var body: some View {
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
                .disabled(
                    player.table != nil ? player.table == table : false
                )
            }
        }
        NavigationLink(destination: PlayerGameView().environment(player), label: {
            Text("Join Game")
        })
        .disabled(player.table == nil)
    }
}

#Preview {
    NavigationStack {
        PlayerTablePickerView(player: PlayerManager(user:"player1", avatar: "trash"))
    }
}
