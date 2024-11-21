//
//  PlayerSelectionView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 24/09/24.
//

import SwiftUI

struct PlayerSelectionView: View {
    @State var name = UUID().uuidString
    @State var systemImage = "vision.pro"
    let emojiOptions = ["vision.pro", "person.crop.square", "american.football", "cloud.bolt"]
    
    var body: some View {
        Form {
            TextField("username", text: $name)
            // Picker
            Picker(selection: $systemImage, label: Text("Pick your avatar")) {
                ForEach(emojiOptions, id: \.self) { emoji in
                    Image(systemName: emoji).tag(emoji)
                }
            }
        }
        NavigationLink(destination: {
            if !name.isEmpty {
                PlayerTablePickerView(player: PlayerManager(user: name, avatar: systemImage))
            } else {
                EmptyView()
            }
        }) {
            Text("Start Game")
        }
        .disabled(name.isEmpty)
    }
}

#Preview {
    NavigationStack {
        PlayerSelectionView()
    }
}
