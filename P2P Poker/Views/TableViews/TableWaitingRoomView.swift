//
//  TableView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import SwiftUI

struct TableWaitingRoomView: View {
    @Binding var tableVM: TableViewModel
    
    var body: some View {
        if let table = self.tableVM.tableManager {
            List {
                ForEach(table.playersInSession, id: \.self){
                    player in
                    Text(player.displayName)
                }
            }
            Button("Start Game"){
                do {
                    try table.beginGame()
                } catch {
                    print(error)
                }
                
            }
        } else {
            ProgressView()
        }
        
    }
}
