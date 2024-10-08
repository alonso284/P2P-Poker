//
//  PlayerGameView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 24/09/24.
//

import SwiftUI

struct PlayerGameView: View {
    @EnvironmentObject var player: PlayerManager
    @State private var bet: Double = 0
    
    var body: some View {
        List {
            Section("Player") {
                HStack {
                    Spacer()
                    // FIXME Looks bad
                    VStack {
                        Image(systemName: player.avatar)
                            .font(.largeTitle)
                            .padding()
                        Text(player.playerID.displayName)
                            .font(.body)
                    }
                    Spacer()
                }
                .padding()
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text("\(player.getBalance())")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        Text("Current Balance")
                    }
                    Spacer()
                }
                .padding()
            }
            
            Section("Current Round"){
                if let hand = self.player.getHand(){
                    HStack {
                        Spacer()
                        CardView(card: hand.0)
                        Spacer()
                        CardView(card: hand.1)
                        Spacer()
                    }
                    
                    if let currentRaise = self.player.currentRaise {
                        HStack {
                            Spacer()
                            Text("Amount to complete: \(currentRaise)")
                            Spacer()
                        }
                        if currentRaise < self.player.getBalance() {
                            Slider(value: $bet, in: Double(currentRaise)...Double(self.player.getBalance()), step: 1.0)
                            Button("Raise \(bet)"){
                                self.player.playTurn(amount: Int(bet))
                            }
                            .onAppear(){ bet = 0.0 }
                            Button("Call"){
                                self.player.playTurn(amount: currentRaise)
                            }
                        }
                        if currentRaise >= self.player.getBalance() {
                            Button("All-In"){
                                self.player.playTurn(amount: self.player.getBalance())
                            }
                        }
                        
                        if currentRaise == 0 {
                            Button("Check"){
                                self.player.playTurn(amount: 0)
                            }
                        } else {
                            Button("Fold"){
                                self.player.playTurn(amount: 0)
                            }
                        }
                    }
                    else {
                        ContentUnavailableView {
                            Label("Waiting for turn", systemImage: "clock")
                        }
                    }
                }
                else {
                    ContentUnavailableView {
                        Label("Starting round", systemImage: "hands.sparkles")
                    }
                }
                    
                
            }
            
        }
    }
}

#Preview {
    @ObservedObject var player = PlayerManager(user: "Alonso", avatar: "vision.pro")
    PlayerGameView()
        .environmentObject(player)
}
