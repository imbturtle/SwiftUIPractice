import SwiftUI

struct TicTacToeGameView: View {
  @StateObject var gameViewModel = TicTacToeGameViewModel()
  
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text("Player One:")
        Text("\(gameViewModel.players.score.0)")
        Spacer()
        Text("Player Two:")
        Text("\(gameViewModel.players.score.1)")
        Spacer()
      }
      HStack {
        Text("Who's turn:")
        Text("\(gameViewModel.players.whosTurn == .one ? "Player One" : "Player Two")")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(gameViewModel.players.whosTurn == .one ? Color.pink : Color(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)))
      }
      Group {
        HStack {
          ForEach((0...2), id:\.self) { index in
            showSquare(index)
          }
        }
        HStack {
          ForEach((3...5), id:\.self) { index in
            showSquare(index)
          }
        }
        HStack {
          ForEach((6...8), id:\.self) { index in
            showSquare(index)
          }
        }
      }
      Spacer()
    }
    .padding()
    .alert("Game End",
           isPresented: $gameViewModel.showEndGameAlert,
           actions: {
      Button("One More") {
        gameViewModel.oneMore()
      }
      Button("Leave", role: .cancel) {
        gameViewModel.reset()
      }
    }, message: {
      Text("\(gameViewModel.winner)")
    })
    .animation(.easeInOut, value: gameViewModel.players.whosTurn)
    .sheet(isPresented: $gameViewModel.showStarupSheet) {
      StarUpView(gameViewModel: gameViewModel)
    }
  }
  
  func showSquare(_ index: Int) -> some View {
    return ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.gray)
        .aspectRatio(1, contentMode: .fit)
      showDecision(index)
    }
    .gesture(gameViewModel.tapToDecision(index), including: gameViewModel.players.id == .human ? .all : .subviews )
  }
  
  @ViewBuilder func showDecision(_ index: Int) -> some View {
    if let decision = gameViewModel.playersDecisions[index] {
      switch decision {
      case .one:
        Circle()
          .stroke(Color.pink, lineWidth: 10)
          .aspectRatio(1.0, contentMode: .fit)
          .padding(10)
      case .two:
        Image(systemName: "plus")
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .rotationEffect(Angle(degrees: 45))
          .foregroundColor(Color(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)))
      }
    }
  }
}


struct StarUpView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var gameViewModel: TicTacToeGameViewModel
  
  var body: some View {
    VStack{
      Picker(selection: $gameViewModel.players.gameType) {
        Text("Player vs Player").tag(0)
        Text("Player vs Bot").tag(1)
      } label: {
        Text("Play Type")
      }
      .pickerStyle(MenuPickerStyle())
      
      Button("GO!") {
        dismiss()
      }
    }
  }
}
