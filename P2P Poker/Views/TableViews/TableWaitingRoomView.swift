//
//  TableView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import SwiftUI

struct TableWaitingRoomView: View {
    @State var table: TableManager
    
    var body: some View {
        List {
            ForEach(self.table.playersInSession, id: \.self){
                player in
                Text(player.displayName)
            }
        }
        NavigationLink("Start Game", destination: {
            TableGameView().environment(table)
        })
    }
}

#Preview {
    NavigationStack {
        TableWaitingRoomView(table: TableManager(name: "Table"))
    }
}
