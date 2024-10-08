//
//  ClientManager.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import Foundation
import MultipeerConnectivity

class PlayerManager: NSObject, ObservableObject {
    let avatar: String
    @Published private var balance: Int = 0
    @Published private var hand: (Card, Card)?
    @Published var currentRaise: Int?
    
    let playerID: MCPeerID
    let session: MCSession
    
    // Look for tables
    let discovery: MCNearbyServiceBrowser
    @Published var availableTables = [MCPeerID]()
    @Published var table: MCPeerID?

    init(user: String, avatar: String) {
        self.avatar = avatar
        self.playerID = MCPeerID(displayName: user)
        self.session = MCSession(peer: self.playerID)
        self.discovery = MCNearbyServiceBrowser(peer: self.playerID, serviceType: "P2PPoker")
        super.init()
        self.session.delegate = self
        self.discovery.delegate = self
        self.startBrowsingForPeers()
    }
    
    deinit {
        stopBrowsingForPeers()
    }
    
    // Get methods
    func getBalance() -> Int {
        return self.balance
    }
    
    func getHand() -> (Card, Card)? {
        return self.hand
    }
    
    func startBrowsingForPeers() {
        self.discovery.startBrowsingForPeers()
    }
    
    func stopBrowsingForPeers() {
        self.discovery.stopBrowsingForPeers()
        self.availableTables.removeAll()
    }
    
    func playTurn(amount: Int) {
        self.send(action: PlayerAction(action: .play(amount)))
    }
    
    func send(action: PlayerAction) {
        guard let table = self.table else { return }
        guard let data = action.data() else { return }
        do {
            try self.session.send(data, toPeers: [table], with: .reliable)
        } catch {
            print("unairble to send action: \(error)")
        }
    }
    
    func join(table: MCPeerID) {
        let contextData: Data?
        do {
            contextData = try JSONEncoder().encode(self.avatar)
        } catch {
            print("Failed to encode avatar: \(error.localizedDescription)")
            contextData = nil
        }
        self.discovery.invitePeer(table, to: self.session, withContext: contextData, timeout: 10)
    }
}

extension PlayerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !availableTables.contains(peerID) {
            availableTables.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = availableTables.firstIndex(of: peerID) {
            availableTables.remove(at: index)
        }
    }
}

extension PlayerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("receivced state: \(state.rawValue)")
        switch state {
        case .connected:
            table = peerID
        case .notConnected:
            print("not success")
        default:
            return
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let pokerAction = try? JSONDecoder().decode(TableAction.self, from: data) {
            switch pokerAction.action {
            case .beginround(let card1, let card2):
                self.hand = (card1, card2)
            case .endround(let winnings):
                self.balance += winnings
                
            case .begingame(let balance):
                self.balance = balance
            case .endgame(let winState):
//                self.winState = winState
                return
                
            case .turn(let tablePot):
                self.currentRaise = tablePot
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
