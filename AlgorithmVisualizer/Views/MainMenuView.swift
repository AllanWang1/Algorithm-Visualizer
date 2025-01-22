import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var stateMachine: StateMachine
    @EnvironmentObject var settings: Settings
    @State private var showSettings: Bool = false
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Welcome to Algorithm Visualizer")
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .foregroundColor(Color.blue)
                Spacer()
                VStack {
                    Button {
                        stateMachine.appState = .sort
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(Color.teal)
                                .frame(width: 400, height: 150)
                            Text("Sorting Algorithms")
                                .font(.system(size: 24))
                                .fontWeight(.black)
                                .foregroundStyle(Color.white)
                        }
                    }
                    Button {
                        stateMachine.appState = .maze
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(Color.teal)
                                .frame(width: 400, height: 150)
                            Text("BFS and DFS Maze Solver")
                                .font(.system(size: 24))
                                .fontWeight(.black)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            stateMachine.appState = .settings
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(Color.gray)
                                .frame(width: 100)
                                .padding()
                            Image(systemName: "gear")
                                .font(.system(size: 60))
                                .padding()
                                .foregroundStyle(Color.white)
                        }
                    }
                }
            }
        }
    }
}
