import SwiftUI

enum WhosTurn: Int {
  case one, two
  
  mutating func toggle() {
    switch self {
    case .one:
      self = .two
    case .two:
      self = .one
    }
  }
}

enum Id {
  case human, robot
}

struct PlayersInformation {
  var ids: (Id, Id) {
    gameType == 0 ? (Id.human, Id.human) : ( Id.human, Id.robot)
  }
  var score: (Int, Int) = (0, 0)
  var whosTurn = WhosTurn.one
  var id: Id {
    whosTurn.rawValue == 0 ? ids.0 : ids.1
  }
  var gameType: Int = 0
}


final class TicTacToeGameViewModel: ObservableObject {
  
  @Published var playersDecisions: [WhosTurn?] = Array(repeating: nil, count: 9)
  @Published var playerOneDecisions = [Int]()
  @Published var playerTwoDecisions = [Int]()
  @Published var players: PlayersInformation = PlayersInformation()
  @Published var showEndGameAlert: Bool = false
  @Published var showStarupSheet: Bool = true
  @Published var winner: String = ""
  
  internal func oneMore() {
    playersDecisions = Array(repeating: nil, count: 9)
    playerOneDecisions = [Int]()
    playerTwoDecisions = [Int]()
  }
  
  internal func reset() {
    playersDecisions = Array(repeating: nil, count: 9)
    playerOneDecisions = [Int]()
    players = PlayersInformation()
    playerTwoDecisions = [Int]()
    showStarupSheet = true
  }
  
  internal func tapToDecision(_ index: Int) -> some Gesture{
    TapGesture(count: 1)
      .onEnded { [self] in
        guard playersDecisions[index] == nil else { return }
        playersDecisions[index] = players.whosTurn
        recordDecision(index)
        if players.id == .robot {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
            switch players.whosTurn {
            case .one:
              botDecision(&playerOneDecisions, enemyDecisions: &playerTwoDecisions)
              break
            case .two:
              botDecision(&playerTwoDecisions, enemyDecisions: &playerOneDecisions)
            }
            checkWinner()
          }
        }
      }
  }
  
  internal func recordDecision(_ index: Int) {
    switch players.whosTurn {
    case .one:
      playerOneDecisions.append(index)
    case .two:
      playerTwoDecisions.append(index)
    }
    checkWinner()
  }
  
  internal func checkWinner() {
    let winPatterns: Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    switch players.whosTurn {
    case .one:
      for winPattern in winPatterns {
        if winPattern.isSubset(of: playerOneDecisions) {
          winner = "player one win"
          players.score.0 += 1
          showEndGameAlert = true
        }
      }
      
    case .two:
      for winPattern in winPatterns {
        if winPattern.isSubset(of: playerTwoDecisions) {
          winner = "player two win"
          players.score.1 += 1
          showEndGameAlert = true
        }
      }
    }
    players.whosTurn.toggle()
    if !playersDecisions.contains(nil) {
      winner = "Game ended in a tie."
      showEndGameAlert = true
    }
  }
  
  
  internal func botDecision(_ selfDecisions: inout [Int], enemyDecisions: inout [Int]) {
    let winPatterns: Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    //check win chance
    for winPattern in winPatterns {
      let nextDecision = winPattern.subtracting(selfDecisions)
      if nextDecision.count == 1 && playersDecisions[nextDecision.first!] == nil {
        playersDecisions[nextDecision.first!] = players.whosTurn
        selfDecisions.append(nextDecision.first!)
        return
      }
    }
    //block lose chance
    for winPattern in winPatterns {
      let enemyNextDecision = winPattern.subtracting(enemyDecisions)
      if enemyNextDecision.count == 1 && playersDecisions[enemyNextDecision.first!] == nil {
        playersDecisions[enemyNextDecision.first!] = players.whosTurn
        selfDecisions.append(enemyNextDecision.first!)
        return
      }
    }
    //take center position
    if playersDecisions[4] == nil {
      playersDecisions[4] = players.whosTurn
      selfDecisions.append(4)
      return
    }
    //random position
    repeat {
      let nextDecision = Int.random(in: 0...8)
      if playersDecisions[nextDecision] == nil {
        playersDecisions[nextDecision] = players.whosTurn
        selfDecisions.append(nextDecision)
        return
      }
    } while true
  }
}
