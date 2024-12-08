//
//  TableGameView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 08/10/24.
//

import SwiftUI

struct TableGameView: View {
    @Binding var tableVM: TableViewModel
    
    var body: some View {
        if let table = tableVM.tableManager {
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
                            try table.beginGame()
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Button("Begin Round"){
                    DispatchQueue.main.async {
                        do {
                            try table.beginRound()
                        } catch {
                            print(error)
                        }
                    }
                }
                .disabled(table.tableState != .inGame || table.tableState == .idle)
                
                
                Section("Player In Game"){
                    ForEach(table.playersInGame){
                        player in
                        HStack {
                            if(table.currentTurn == player.id){
                                Image(systemName: "hourglass")
                                    .foregroundStyle(.red)
                            }
                            Text(player.id.displayName)
                                .foregroundStyle(table.lastToBegin == player.id ? .blue : .primary)
                            Spacer()
                            Text("Balance: \(player.balance)")
                        }
                    }
                }
                
                Section("Players In Waiting Room"){
                    ForEach(table.playersInWaitingRoom, id: \.self){
                        player in
                        HStack {
                            Text(player.displayName)
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
}

