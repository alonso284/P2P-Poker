//
//  ContentView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import SwiftUI
import SwiftData
import MultipeerConnectivity

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: TableSelectionView()) {
                        Text("Host name")
                    }
                    Spacer()
                    NavigationLink(destination: PlayerSelectionView()) {
                        Text("Join name")
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
}
