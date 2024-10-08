//
//  TableView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import SwiftUI

struct TableWaitingRoomView: View {
    @StateObject var table: TableManager
    
    var body: some View {
        List {
            ForEach(table.players, id: \.self){
                player in
                Text(player.displayName)
            }
        }
        NavigationLink("Start Game", destination: {
            TableGameView().environmentObject(table)
        })
    }
}

#Preview {
    NavigationStack {
        TableWaitingRoomView(table: TableManager(name: "Table1"))
    }
}
