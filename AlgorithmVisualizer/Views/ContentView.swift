import SwiftUI

struct ContentView: View {
    @StateObject private var stateMachine: StateMachine = StateMachine()
    @StateObject private var settings: Settings = Settings()
    
    
    var body: some View {
        switch stateMachine.appState {
        case .mainMenu:
            MainMenuView()
                .environmentObject(stateMachine)
                .environmentObject(settings)
        case .maze:
            MazeView(settings.mazeCOLS, settings.mazeROWS, settings.mazeCellSize)
                .environmentObject(stateMachine)
                .environmentObject(settings)
        case .sort:
            SortView()
                .environmentObject(stateMachine)
                .environmentObject(settings)
        case .settings:
            ZStack {
                MainMenuView()
                Color.gray.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            stateMachine.appState = .mainMenu
                        }
                    }
                
                //ultraThinMaterial will blur what is behind the settings menu
                SettingsView()
                    .frame(maxWidth: 700, maxHeight: 900)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .transition(.scale)
                    .environmentObject(stateMachine)
                    .environmentObject(settings)
            }
        }
    }
}

#Preview {
    ContentView()
}
