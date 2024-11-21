//
//  PlayerGameView.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 24/09/24.
//

import SwiftUI

struct PlayerGameView: View {
    let chips:[(value: Int, color: Color)] = [
        (value: 1, color: .white),
        (value: 5, color: .red),
        (value: 10, color: .blue),
        (value: 25, color: .green),
        (value: 100, color: .black),
        (value: 500, color: .purple),
        (value: 1000, color: .yellow),
        (value: 5000, color: .orange)
    ]
    @Environment(PlayerManager.self) var player: PlayerManager
    @State private var bet: Double = 0
    @State private var showingCard: Bool = false
    @State private var helpView: Bool = false
    
    
    var body: some View {
        List {
            Section("Player") {
//                HStack {
//                    Spacer()
//                    // FIXME Looks bad
//                    VStack {
//                        Image(systemName: player.avatar)
//                            .font(.largeTitle)
//                            .padding()
//                        Text(player.playerID.displayName)
//                            .font(.body)
//                    }
//                    Spacer()
//                }
//                .padding()
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text("\(player.balance)")
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
                if let hand = self.player.hand {
                    HStack {
                        Spacer()
                        if showingCard {
                            
                            CardView(card: hand.0)
                            Spacer()
                            CardView(card: hand.1)
                        } else {
                            ContentUnavailableView {
                                Label("Click to show hand", systemImage: "hands.sparkles")
                            }
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        showingCard.toggle()
                    }
                
                    
                    if let tableRaise = self.player.tableRaise {
                        HStack {
                            Spacer()
                            Text("Amount to complete: \(tableRaise)")
                            Spacer()
                        }
                        // Raise
                        if tableRaise <= self.player.balance {
                            Slider(value: $bet, in: Double(0)...Double(self.player.balance))
                            Button("Raise \(Int(bet))"){
                                self.player.playTurn(amount: Int(bet))
                            }
                            .onAppear(){ bet = 0.0 }
                        }
                        // Call
                        if tableRaise != 0 && tableRaise <= self.player.balance {
                            Button("Call"){
                                self.player.playTurn(amount: tableRaise)
                            }
                        }
                        // Currently not available
                        // All-In
//                        if currentBid >= self.player.getBalance() {
//                            Button("All-In"){
//                                self.player.playTurn(amount: self.player.getBalance())
//                            }
//                        }
                        
                        if tableRaise == 0 {
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
                Button("Ping Table"){
                    self.player.ping()
                }
                
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            Button(action: {
                helpView.toggle()
            }, label: {
                Image(systemName: "questionmark.circle")
            })
        }
        .sheet(isPresented: $helpView) {
            ExamplesView()
        }
        
    }
}

#Preview {
    @Previewable var player = PlayerManager(user: "Alonso", avatar: "vision.pro")
    NavigationStack {
        PlayerGameView()
            .environment(player)
    }
}
