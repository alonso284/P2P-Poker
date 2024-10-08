//
//  ServerManager.swift
//  P2P Poker
//
//  Created by Alonso Huerta on 23/09/24.
//

import MultipeerConnectivity

// TODO LOGIC
// Secondary Pot
// If a player is paused
// If a player is out of money
// If a player quites middle game


class TableManager: NSObject, ObservableObject {
    @Published var players = [MCPeerID]()
    @Published var playingGame: Bool = false
    @Published var playingRound: Bool = false
    
    class Player {
        @Published var balance: Int
        @Published var hand: (Card, Card)?
        @Published var sectionBalance: Int = 0
        
        @Published var playingRound: Bool = true
        @Published var playingGame: Bool = true
        
        init(balance: Int) {
            self.balance = balance
        }
    }
    
    // Reset per game
    @Published private var playerInfo: [MCPeerID: Player] = [:]
    @Published private var lastToBegin : MCPeerID?
    @Published private var currentTurn : MCPeerID?
    @Published private var lastToRaise : MCPeerID?
    @Published var pot: Int = 0
    
    // Reset per Round
    @Published private var deck = [Card]()
    
    // Reset per section
    @Published private var currentBid: Int = 0
    @Published var board: [Card] = []
    
    let tableID: MCPeerID
    let session: MCSession
    let advertiser: MCNearbyServiceAdvertiser
    
    init(name: String) {
        self.tableID = MCPeerID(displayName: name)
        self.session = MCSession(peer: self.tableID)
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.tableID, discoveryInfo: nil, serviceType: "P2PPoker")
        super.init()
        self.startAdvertisingPeer()
        self.advertiser.delegate = self
        self.session.delegate = self
    }
    
    deinit {
        stopAdvertisingPeer()
    }
    
    func getAmountOfPlayers() -> Int {
        self.players.count
    }
    
    func startAdvertisingPeer() {
        self.advertiser.startAdvertisingPeer()
    }
    
    // FIXME, stop advertising once game started
    func stopAdvertisingPeer() {
        self.advertiser.stopAdvertisingPeer()
    }
    
    func sendToPlayer(action: TableAction, player: MCPeerID){
        guard let data = action.data() else { return }
        do {
            try self.session.send(data, toPeers: [player], with: .reliable)
        } catch {
            print("unable to send action: \(error)")
        }
    }
    
    func sendToPlayers(action: TableAction){
        guard let data = action.data() else { return }
        do {
            try self.session.send(data, toPeers: self.players, with: .reliable)
        } catch {
            print("unable to send action: \(error)")
        }
    }
    
    func sendToPlayers(action: TableAction, players: [MCPeerID]){
        guard let data = action.data() else { return }
        do {
            try self.session.send(data, toPeers: players, with: .reliable)
        } catch {
            print("unable to send action: \(error)")
        }
    }
}

// Game Logic
extension TableManager {
    func beginGame() {
        self.playingGame = true
        self.players.shuffle()
        // FIXME
        self.lastToBegin = self.players.last!
        
        // FIXME make it editable
        for player in self.players {
            self.playerInfo[player] = .init(balance: 500)
        }
        self.sendToPlayers(action: TableAction(action: .begingame(500)))
    }
    
    func getAmountOfActivePlayers() -> Int {
        return self.playerInfo.values.filter { $0.playingRound }.count
    }
    
    func resetDeck() {
        deck.removeAll()
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        deck.shuffle()
    }
    
     func getHandFromDeck() -> (Card, Card){
        let card1 = deck.removeFirst()
        let card2 = deck.removeFirst()
        return (card1, card2)
    }
    
    func getCardFromDeck() -> Card {
        return deck.removeFirst()
    }
    
    // FIXME
    func nextPlayer(player: MCPeerID?) -> MCPeerID? {
        guard let player = player else { return nil }
        
        let index = self.players.firstIndex(of: player)!
        let nextIndex = index.advanced(by: 1)
        
        // FIXME Check if it is active
        if nextIndex >= self.players.endIndex {
            return self.players.first
        } else {
            return self.players[nextIndex]
        }
    }
    
    // FIXME check for hands
    func getWinner() -> MCPeerID? {
        for (player, playerInfo) in self.playerInfo {
            if playerInfo.playingRound { return player }
        }
        return nil
    }
    
    func removePlayerFromRound(player: MCPeerID) {
        self.playerInfo[player]?.playingRound = false
    }
    
    // returns whether or not the game should continue
    func nextSection() -> Bool {
        for (_, playerInfo) in self.playerInfo {
            self.pot += playerInfo.sectionBalance
            playerInfo.sectionBalance = 0
        }
        
//        if getAmountOfActivePlayers() == 1 {
//            return false
//        }
        if self.board.isEmpty {
            self.board.append(self.getCardFromDeck())
            self.board.append(self.getCardFromDeck())
            self.board.append(self.getCardFromDeck())
            return true
        } else if self.board.count == 5 {
            return false
        } else {
            self.board.append(self.getCardFromDeck())
            return true
        }
    }
    
    func resetTable(){
        self.currentBid = 0
        self.board.removeAll()
    }
    
    func beginRound() {
        self.playingRound = true
        // Reset board
        resetTable()
        self.resetDeck()
        
        // FIXME Get the first player
        self.lastToBegin = nextPlayer(player: self.lastToBegin!)
        if let id = self.lastToBegin {
            print(id.displayName)
        }
        self.currentTurn = self.lastToBegin
        self.lastToRaise = self.currentTurn
        
        for player in self.players {
            if let playerInfo = self.playerInfo[player] {
                let hand = self.getHandFromDeck()
                playerInfo.hand = hand
                self.sendToPlayer(action: TableAction(action: .beginround(hand.0, hand.1)), player: player);
            }
        }
        self.sendToPlayer(action: TableAction(action: .turn(0)), player: self.currentTurn!)
    }
}

extension TableManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if !self.players.contains(peerID) {
            DispatchQueue.main.async {
                self.players.append(peerID)
            }
            invitationHandler(true, self.session)
        } else {
            invitationHandler(false, nil)
        }
    }
}

extension TableManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if !self.players.contains(peerID) {
                DispatchQueue.main.async {
                    self.players.append(peerID)
                }
            }
        case .notConnected:
            //  FIXME, if in game, take as fold
            if let index = self.players.firstIndex(of: peerID) {
                DispatchQueue.main.async {
                    self.players.remove(at: index)
                }
            }
        default:
            return
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let pokerAction = try? JSONDecoder().decode(PlayerAction.self, from: data) {
            switch pokerAction.action {
            case .play(let amount):
                if let player = self.playerInfo[peerID] {
                    player.balance -= amount
                    player.sectionBalance += amount
                    
                    if player.sectionBalance < self.currentBid {
                        removePlayerFromRound(player: peerID)
                    }
                    
                    // FIXME
                    self.currentTurn = nextPlayer(player: self.currentTurn!)
                    if self.currentTurn == self.lastToRaise {
                        self.playingRound = self.nextSection()
                        if !self.playingRound {
                            // FIXME
                            let winner = getWinner()!
                            let losers = self.players.filter { $0 != winner }
                            self.sendToPlayers(action: TableAction(action: .endround(0)), players: losers)
                            self.sendToPlayer(action: TableAction(action: .endround(pot)), player: winner)
                            pot = 0
                            
                            resetTable()
                        } else {
                            self.currentTurn = self.lastToBegin
                            self.lastToRaise = self.currentTurn
                        }
                    } else {
                        let increment = self.currentBid - player.sectionBalance
                        self.sendToPlayer(action: TableAction(action: .turn(increment)), player: self.currentTurn!)
                    }
                }
                return
            case .status(let state):
                return
            case .exit:
                return
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
