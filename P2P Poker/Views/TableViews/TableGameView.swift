//
//  TableGameView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 08/10/24.
//

import SwiftUI

struct TableGameView: View {
    @Environment(TableManager.self) var table: TableManager
    
    var body: some View {
        List {
            HStack {
                Spacer()
                ForEach(table.board){
                    card in
                    CardView(card: card)
                    Spacer()
                }
            }
            Text("\(table.pot)")
            
            
            // DELETE ME
            Button("Begin Game"){
                DispatchQueue.main.async {
                    do {
                        try self.table.beginGame()
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Begin Round"){
                DispatchQueue.main.async {
                    do {
                        try self.table.beginRound()
                    } catch {
                        print(error)
                    }
                }
            }
            .disabled(self.table.tableState != .inGame || self.table.tableState == .idle)
            
            
            Section("Player In Game"){
                ForEach(self.table.playersInGame){
                    player in
                    HStack {
                        if(self.table.currentTurn == player.id){
                            Image(systemName: "hourglass")
                                .foregroundStyle(.red)
                        }
                        Text(player.id.displayName)
                            .foregroundStyle(self.table.lastToBegin == player.id ? .blue : .primary)
                        Spacer()
                        Text("Balance: \(player.balance)")
                    }
                }
            }
            
            Section("Players In Waiting Room"){
                ForEach(self.table.playersInWaitingRoom, id: \.self){
                    player in
                    HStack {
                        Text(player.displayName)
                    }
                }
            }        }
    }
}

#Preview {
    @Previewable var table = TableManager(name: "Table")
    TableGameView()
        .environment(table)
}
