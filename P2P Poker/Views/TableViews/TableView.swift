//
//  TableView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 21/11/24.
//

import SwiftUI

struct TableView: View {
    @State var tableVM: TableViewModel = TableViewModel()
    var body: some View {
        if let table = self.tableVM.tableManager {
            if table.tableState != .idle {
                TableGameView(tableVM: $tableVM)
            } else {
                TableWaitingRoomView(tableVM: $tableVM)
            }
        } else {
            TableSelectionView(tableVM: $tableVM)
        }
    }
}

#Preview {
    TableView()
}
