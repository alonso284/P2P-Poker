//
//  TableGameView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 08/10/24.
//

import SwiftUI

struct TableGameView: View {
    @EnvironmentObject var table: TableManager
    
    var body: some View {
        List {
            HStack {
                ForEach(table.board){
                    card in
                    CardView(card: card)
                }
            }
            Text("\(table.pot)")
            
            // DELETE ME
            Button("Begin Game"){
                table.beginGame()
            }
            .disabled(self.table.playingGame)
            
            Button("Begin Round"){
                table.beginRound()
            }
            .disabled(self.table.playingRound)
            
            Button("Next Session"){
                table.nextSection()
            }
        }
    }
}

#Preview {
    @ObservedObject var table = TableManager(name: "Table1")
    TableGameView()
        .environmentObject(table)
}
