//
//  ClientManager.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import Foundation
import MultipeerConnectivity

@Observable
class PlayerManager: NSObject {
    /// Emoji for the user
    let avatar: String
    /// Player balance for a game
    private(set) var balance: Int = 0
    /// Amount played in the round
    /// Player balance for a round
    private(set) var hand: (Card, Card)?
    /// Amount being played in table
    private(set) var tableRaise: Int?
    
    /// Player Metadata
    private let playerID: MCPeerID
    private var session: MCSession
    
    /// Discovery varaibles (for looking for tables)
    private let discovery: MCNearbyServiceBrowser
    private(set) var availableTables = [MCPeerID]()
    private(set) var table: MCPeerID?

    // FIXME: Make this cleaner
    init(user: String, avatar: String) {
        self.avatar = avatar
        self.playerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: self.playerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        self.discovery = MCNearbyServiceBrowser(peer: self.playerID, serviceType: "P2PPoker")
        super.init()
        self.session.delegate = self
        self.discovery.delegate = self
        self.startBrowsingForPeers()
    }
    
    deinit {
        stopBrowsingForPeers()
    }
    
    private func startBrowsingForPeers() {
        self.discovery.startBrowsingForPeers()
    }
    
    private func stopBrowsingForPeers() {
        self.discovery.stopBrowsingForPeers()
        self.availableTables.removeAll()
    }
    
    func playTurn(amount: Int) {
        self.send(action: PlayerAction(action: .play(amount)))
    }
    
    func ping(){
        self.send(action: PlayerAction(action: .ping))
    }
    
    // FIXME: Handle error gracefully
    private func send(action: PlayerAction) {
        guard let table = self.table else { return }
        guard let data = action.data() else { return }
        print("Attempting to send action to table: \(table.displayName)")
        
        // Check if the peer is connected
        if self.session.connectedPeers.contains(table) {
            do {
                try self.session.send(data, toPeers: [table], with: .reliable)
                DispatchQueue.main.async {
                    self.tableRaise = nil
                }
            } catch {
                print("Unable to send action: \(error)")
            }
        } else {
            print("Error: Peer is not connected. Cannot send action.")
        }
    }
    
    func join(table: MCPeerID) {
//        let contextData: Data?
//        do {
//            contextData = try JSONEncoder().encode(self.avatar)
//        } catch {
//            print("Failed to encode avatar: \(error.localizedDescription)")
//            contextData = nil
//        }
        self.discovery.invitePeer(table, to: self.session, withContext: nil, timeout: 10)
    }
}

extension PlayerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availableTables.contains(peerID) {
                self.availableTables.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availableTables.removeAll(where: { $0 == peerID })
        }
    }
}

extension PlayerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Succesfully connected to table")
                DispatchQueue.main.async {
                    self.table = peerID
                    self.discovery.stopBrowsingForPeers()
                }
            case .notConnected:
                print("Disconnected from table")
            case .connecting:
                print("Connecting to table")
            @unknown default:
                print("Unknown state")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            print("Received action from \(peerID)")
            if let pokerAction = try? JSONDecoder().decode(TableAction.self, from: data) {
                switch pokerAction.action {
                case .ping:
                    print("Pinged by table")
                case .beginround(let card1, let card2):
                    print("Received cards: \(card1.id) \(card2.id)")
                    self.hand = (card1, card2)
                case .endround(let newBalance):
                    print("Round ended, rewarded \(newBalance)")
                    self.balance = newBalance
                    self.hand = nil
                    print("Current balance: \(self.balance)")
                case .begingame(let newBalance):
                    print("Game started")
                    self.balance = newBalance
                    print("Current balance: \(self.balance)")
                    
                    // FIXME: End game has been reached
                case .endgame(_):
                    //                self.winState = winState
                    return
                case .turn(let call):
                    print("Player's turn, current top bid: \(call)")
                    self.tableRaise = call
                case .newBalance(let newBalance):
                    self.balance = newBalance
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        return
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        return
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        return
    }
}
