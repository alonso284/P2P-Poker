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

@Observable
class TableManager: NSObject {
    // Table meta information
    private let tableID: MCPeerID
    private var session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser

    @Observable
    class PlayerInstance: Identifiable {
        let id: MCPeerID
        enum State {
            // Player can flip from active to waitingIdle. When it's his turn to be Big Blind, they flip to idle
            /// Player is currently playing in game
            case active
            /// Player waiting to become idle
            case waitingIdle
            
            // Player can flip from idle to waitingActive. When it's his turn to be Big Blind, they flip to active
            /// Player is currently only expectatin
            case idle
            /// Player is waiting to jump back into the game
            case waitingActive

        }
        /// Balance avaible to the player
        var balance: Int = 0
        
        // Round variables
        /// Hand during a round
        var hand: (Card, Card)?
        /// Balance during a round
        var roundBalance:   Int = 0
        
        /// Whether the player is active in the current round
        var state: State = .active
        
        /// Whether the player is active in the round
        var isActive: Bool {
            [.active, .waitingIdle].contains(state)
        }
        
        /// Balance in initiated equally for all players
        init(id: MCPeerID){
            self.id = id
        }
        
        func resetRound() {
            self.roundBalance = 0
            self.hand = nil
        }
    }

    /// Game configurations
    var initialBalance: Int = 1000
//    var initialBet: Int = 10
//    var smallBlind: Int { self.initialBet * 1 }
//    var bigBlind:   Int { self.initialBet * 2 }
    
    /// Table state
    enum State {
        case inGame, inRound, idle
    }
    private(set) var tableState = State.idle
    
    // Variables to reset per game
    // FIXME: make pricate
    private(set) var lastToBegin : MCPeerID?
    private(set) var currentTurn : MCPeerID?
    private(set) var lastToRaise : MCPeerID?
    /// Current pot sum
    var pot: Int {
        var sum: Int = 0
        for player in playersInGame {
            sum += player.roundBalance
        }
        return sum
    }
    /// Highest bid yet
    var currentBid: Int {
        var topBid: Int = 0
        for player in playersInGame {
            topBid = max(player.roundBalance, topBid)
        }
        return topBid
    }
    
    /// List of players in the session
    var playersInSession: [MCPeerID] {
        self.session.connectedPeers
    }
    /// List of players in the game. Variable is set to `playersInSession` with init value everytime a game starts.
    private(set) var playersInGame: [PlayerInstance] = []
    /// List of players in the round. Variable is set to `playersInGame` everytime a round starts.
    private(set) var playersInRound: [MCPeerID] = []
    
    /// List of active players
    var playersActive: [PlayerInstance] {
        return playersInGame.filter { $0.isActive == true }
    }
    /// List of idle players
    var playersIdle: [PlayerInstance] {
        return playersInGame.filter { $0.isActive == false }
    }
    /// Player that are in session but not in game (those who don't have a player instace)
    var playersInWaitingRoom: [MCPeerID] {
        return playersInSession.filter { sessionPlayer in
            // Ensure playersInGame contains the same type or can be compared to MCPeerID
            !playersInGame.contains { gamePlayer in
                // Custom comparison logic if necessary
                sessionPlayer == gamePlayer.id
            }
        }
    }
    
    // Reset per Round
    private var deck = [Card]()
    

    // FIXME: Make private
    private(set) var board: [Card] = []
    
    // FIXME: Cleanup
    init(name: String) {
        // FIXME: Name customization
        self.tableID = MCPeerID(displayName: name)
        self.session = MCSession(peer: self.tableID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.tableID, discoveryInfo: nil, serviceType: "P2PPoker")
        super.init()
        self.advertiser.delegate = self
        self.session.delegate = self
        self.startAdvertisingPeer()
    }
    
    deinit {
        stopAdvertisingPeer()
    }
    
    private func startAdvertisingPeer() {
        self.advertiser.startAdvertisingPeer()
    }
    
    private func stopAdvertisingPeer() {
        self.advertiser.stopAdvertisingPeer()
    }
    
    /// Send a TableAction to a player
    // FIXME: handle error
    private func sendToPlayer(action: TableAction, player: MCPeerID){
        guard let data = action.data() else { return }
        print("Sending message to \(player): \(action)")
        do {
            try self.session.send(data, toPeers: [player], with: .reliable)
        } catch {
            print("unable to send action: \(error)")
        }
    }
}

/// Game components
extension TableManager {
    /// From the current game, get the next player to begin
    private func nextToBegin() throws -> MCPeerID {
        if(self.tableState != .inRound){
            // FIXME: thorow error, as player is not in round
            throw NSError(domain: "Not in round", code: 400)
        }
        if(self.playersActive.count < 2){
            // FIXME: thorow error, as player is not in round
            throw NSError(domain: "Not enough players in round", code: 400)
        }
        guard let lastToBegin = self.lastToBegin else {
            return self.playersInRound.first!
        }
        
        // Find the next player in the list
        if let currentIndex = self.playersInGame.firstIndex(where: { $0.id == lastToBegin }) {
            for next in 1..<self.playersInGame.count {
                let indx = (currentIndex + next) % self.playersInGame.count
                
                if(self.playersInGame[indx].state == .waitingActive) {
                    self.playersInGame[indx].state = .active
                }
                
                if(self.playersInGame[indx].isActive) {
                    return self.playersInGame[indx].id
                }
            }
        } else {
            throw NSError(domain: "com.yourdomain.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Player not found."])
        }
       
       // If for some reason the index is not found (which shouldn't happen), throw an error
       throw NSError(domain: "com.yourdomain.error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected error finding the next player."])
    }
    
    private func nextToPlay() throws -> MCPeerID {
        if(self.tableState != .inRound){
            // FIXME: thorow error, as player is not in round
            throw NSError(domain: "Not in round", code: 400)
        }
        if(self.playersInRound.count < 2){
            // FIXME: thorow error, as player is not in round
            throw NSError(domain: "Not enough players in round", code: 400)
        }
        
        guard let currentTurn = self.currentTurn else {
            throw NSError(domain: "Not enough players in round", code: 400)
        }
        
        // Find the next player in the list
        if let currentIndex = self.playersInRound.firstIndex(of: currentTurn) {
            let nextIndex = (currentIndex + 1) % playersInRound.count
            return playersInRound[nextIndex]
        } else {
            throw NSError(domain: "com.yourdomain.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Player not found."])
        }
    }
    
    /// Activates the next section. True if the game continue. false Otherwise
    private func nextSection() -> Bool {
        if self.playersInRound.count == 1 {
            return false
        }
        // Flop
        if self.board.isEmpty {
            print("Showing flop")
                self.board.append(self.deck.removeFirst())
                self.board.append(self.deck.removeFirst())
                self.board.append(self.deck.removeFirst())

            return true
        // All board is shown
        } else if self.board.count == 5 {
            print("Game over")
            return false
        // Next card
        } else {
            print("Showing next card")
            self.board.append(self.deck.removeFirst())

            return true
        }
    }
    
    // FIXME: check for hands
    private func getWinners() -> [MCPeerID] {
        var hand: Hand? = nil
        for player in self.playersInGame {
            if self.playersInRound.contains(player.id) {
                if let playerHand = player.hand,
                   let playerBoardHand = Hand(cards: self.board + [playerHand.0, playerHand.1]) {
                    if hand == nil || playerBoardHand > hand! {
                        hand = playerBoardHand
                    }
                }
            }
        }
        var winners:[MCPeerID] = []
        if let hand {
            print("Winner Hand")
            print(hand)
            for player in self.playersInGame {
                if self.playersInRound.contains(player.id) {
                    if let playerHand = player.hand,
                       let playerBoardHand = Hand(cards: self.board + [playerHand.0, playerHand.1]) {
                        if playerBoardHand == hand {
                            winners.append(player.id)
                        }
                    }
                }
            }
        }
        return winners
    }
    
    private func resetTable(){
        for player in self.playersInGame {
            player.resetRound()
        }
        self.board.removeAll()
        self.deck = freshDeck()
    }
}

// Game Logic
extension TableManager {
    func beginGame() throws {
        if(self.tableState != .idle){
            print("There is a game in progress, all information will be overwritten")
        }
        if(self.playersInSession.count < 2){
            // FIXME: return custpm errpr
            throw NSError(domain: "com.yourdomain.error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Not enough players to start game"])
        }

        print("Starting game")
        // Indicate the game started
        self.tableState = .inGame
        // Restart the list from players in table
        self.playersInGame.removeAll()
        for playerID in self.playersInSession {
            let playerInstace = PlayerInstance(id: playerID)
            
            playerInstace.balance = self.initialBalance
            self.playersInGame.append(playerInstace)
            // Send message to all players indicating the game begun
            self.sendToPlayer(action: TableAction(action: .begingame(playerInstace.balance)), player: playerInstace.id)
        }
        self.playersInGame.shuffle()
        

        print("Player order: \(self.playersInGame)")
        // FIXME: Begin round
    }
    
    func beginRound() throws {
        if(self.tableState != .inGame){
            throw NSError(domain: "com.yourdomain.error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Game not in progress"])
        }
        /// Reset board
        self.resetTable()
        self.tableState = .inRound
        
        // FIXME: Handle turning players from active to idle and viceversa
        
        if self.playersActive.count < 2 {
            throw NSError(domain: "com.yourdomain.error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Not enough players to start round"])
        }
        // Include in round only players that are active
        self.playersInRound = self.playersActive.map(\.self.id)
        
        // FIXME: Get the first player
        self.lastToBegin = try self.nextToBegin()
        self.currentTurn = self.lastToBegin
        self.lastToRaise = self.currentTurn
        print("Big blind is \(self.currentTurn?.displayName ?? "Error")")
        
        // Go through every player and deal their cards
        for player in self.playersInGame {
            if self.playersInRound.contains(player.id) {
                player.hand = (self.deck.removeFirst(), self.deck.removeFirst())
                self.sendToPlayer(action: TableAction(action: .beginround(player.hand!.0, player.hand!.1)), player: player.id);
            }
        }
        self.sendToPlayer(action: TableAction(action: .turn(0)), player: self.currentTurn!)
    }
}

extension TableManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Advertising player")
        invitationHandler(true, self.session)
    }
}

extension TableManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            print("Updating player \(peerID)")
            switch state {
            case .connected:
                print("Connected")
                self.session = session
            case .notConnected:
                print("Disconnected")
                // FIXME: Handle if player inGame
                self.session = session
            case .connecting:
                print("connecting")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            print("Received action from \(peerID)")
            if let pokerAction = try? JSONDecoder().decode(PlayerAction.self, from: data) {
                switch pokerAction.action {
                case .ping:
                    print("Ping")
                    // When a player plays an amount
                case .play(let amount):
                    // FIXME: Handle error gracefully
                    print("Play: \(amount)")
                    if self.currentTurn == peerID, let player = self.playersInGame.first(where: { $0.id == peerID}) {
                        print("Processing play")
                        // Check if play is valid
                        if amount > player.balance {
                            print("Error, player played invalid amount")
                        }
                        
                        // Get the next player
                        do {
                            self.currentTurn = try self.nextToPlay()
                        } catch {
                            print("Could not find next player")
                            print(error)
                            return
                        }
                        
                        if self.currentBid > player.roundBalance + amount {
                            // Fold
                            self.playersInRound.removeAll(where: { $0 == peerID })
                        }
                        
                        // Player Raised
                        if self.currentBid < player.roundBalance + amount {
                            self.lastToRaise = peerID
                        }
                        
                        // Transfer amount from balance to pot
                        // Make sure money is available
                        player.balance      -= amount
                        player.roundBalance += amount
                        self.sendToPlayer(action: TableAction(action: .newBalance(player.balance)), player: peerID)
                        
                        print("Next turn is for \(self.currentTurn!)")
                        if self.currentTurn == self.lastToRaise {
                            print("This was the last player to raise, moving to next section")
                            let continueGame: Bool = self.nextSection()
                            
                            // round has ended
                            if !continueGame {
                                print("Round has ended")
                                // FIXME
                                let winners = self.getWinners()
                                print("Winners:")
                                print(winners)
                                // FIXME: Handle lost coins with variable residue and all-in situations
                                for player in self.playersInGame {
                                    if winners.contains(player.id) {
                                        player.balance += self.pot / winners.count
                                    }
                                    self.sendToPlayer(action: TableAction(action: .endround(player.balance)), player: player.id)
                                }
                                self.tableState = .inGame
                                self.resetTable()
                                // Round cotinues
                            } else {
                                print("Round continues")
                                // The next player is the one who started
                                self.currentTurn = self.lastToBegin
                                self.lastToRaise = self.lastToBegin
                                self.sendToPlayer(action: TableAction(action: .turn(0)), player: self.currentTurn!)
                            }
                        } else {
                            print("Going to next player in section: ")
                            if let player = self.playersInGame.first(where: { $0.id == self.currentTurn }) {
                                self.sendToPlayer(action: TableAction(action: .turn(self.currentBid - player.roundBalance)), player: self.currentTurn!)
                            } else {
                                print("Unknown error, next player could be found")
                            }
                        }
                    } else {
                        print("Unknown error, player is not next to play or is not in the game")
                    }
                    // FIXME: Handle player exiting a round
                case .status:
                    if let player = self.playersInGame.first(where: { $0.id == peerID}) {
                        switch player.state {
                        case .active:
                            player.state = .waitingIdle
                        case .waitingIdle:
                            player.state = .active
                        case .idle:
                            player.state = .waitingActive
                        case .waitingActive:
                            player.state = .idle
                        }
                    } else {
                        print("Unknown error, player could not be found in game, therefore state cannot change")
                    }
                }
            } else {
                print("Unknown error, action could not be parsed")
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
