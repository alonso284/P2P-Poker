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
    @Binding var playerVM: PlayerViewModel
    @State private var bet: Double = 0
    @State private var showingCard: Bool = false
    @State private var helpView: Bool = false
    
    var body: some View {
        if let player = playerVM.playerManager {
            
            List {
                Section(player.name) {
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
                    if let hand = player.hand {
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
                        
                        
                        if let tableRaise = player.tableRaise {
                            HStack {
                                Spacer()
                                Text("Amount to complete: \(tableRaise)")
                                Spacer()
                            }
                            // Raise
                            if tableRaise <= player.balance {
                                Slider(value: $bet, in: Double(0)...Double(player.balance))
                                Button("Raise \(Int(bet))"){
                                    player.playTurn(amount: Int(bet))
                                }
                                .onAppear(){ bet = 0.0 }
                            }
                            // Call
                            if tableRaise != 0 && tableRaise <= player.balance {
                                Button("Call"){
                                    player.playTurn(amount: tableRaise)
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
                                    player.playTurn(amount: 0)
                                }
                            } else {
                                Button("Fold"){
                                    player.playTurn(amount: 0)
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
                        player.ping()
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
        } else {
            ProgressView()
        }
        
    }
}
