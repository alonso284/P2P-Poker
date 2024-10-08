//
//  TableSelectionView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 24/09/24.
//

import SwiftUI

struct TableSelectionView: View {
    @State var name = ""
    
    var body: some View {
        Form {
            TextField("username", text: $name)
        }
        NavigationLink(destination: TableWaitingRoomView(table: TableManager(name: name)).navigationBarBackButtonHidden(true)) {
            Text("Setup Table")
        }
        .disabled(name.isEmpty)
    }
}

#Preview {
    TableSelectionView()
}
