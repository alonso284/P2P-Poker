//
//  PlayerSelectionView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 24/09/24.
//

import SwiftUI

struct PlayerSelectionView: View {
    @Binding var playerVM: PlayerViewModel
    @State var name = UUID().uuidString
    @State var systemImage = "vision.pro"
    let emojiOptions = ["vision.pro", "person.crop.square", "american.football", "cloud.bolt"]
    
    var body: some View {
        Form {
            TextField("username", text: $name)
            Picker(selection: $systemImage, label: Text("Pick your avatar")) {
                ForEach(emojiOptions, id: \.self) { emoji in
                    Image(systemName: emoji).tag(emoji)
                }
            }
        }
        Button("Start") {
            playerVM.initialize(user: name, avatar: systemImage)
        }
        .disabled(name.isEmpty)
    }
}
