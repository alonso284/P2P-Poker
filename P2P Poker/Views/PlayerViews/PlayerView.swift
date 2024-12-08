//
//  PlayerView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 21/11/24.
//

import SwiftUI

struct PlayerView: View {
    @State var playerVM: PlayerViewModel = PlayerViewModel()
    @State var name = UUID().uuidString
    @State var systemImage = "vision.pro"
    let emojiOptions = ["vision.pro", "person.crop.square", "american.football", "cloud.bolt"]
    
    var body: some View {
        if let player = self.playerVM.playerManager {
            if let _ = player.table {
                PlayerGameView(playerVM: $playerVM)
            } else {
                PlayerTablePickerView(playerVM: $playerVM)
            }
        } else {
            PlayerSelectionView(playerVM: $playerVM)
        }
    }
}

#Preview {
    PlayerView()
}
