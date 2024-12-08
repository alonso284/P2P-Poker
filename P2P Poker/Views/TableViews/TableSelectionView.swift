//
//  TableSelectionView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 24/09/24.
//

import SwiftUI

struct TableSelectionView: View {
    @Binding var tableVM: TableViewModel
    @State var name = "table"
    
    var body: some View {
        Form {
            TextField("username", text: $name)
        }
        Button("Start") {
            tableVM.initialize(name: name)
        }
        .disabled(name.isEmpty)
    }
}
