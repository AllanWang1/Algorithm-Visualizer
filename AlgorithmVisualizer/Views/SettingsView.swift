import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var stateMachine: StateMachine
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        
        VStack {
            Text("Settings")
                .font(.system(size: 40))
                .fontWeight(.heavy)
                .padding()
            // toggles for maze settings
            VStack {
                HStack {
                    Text("Maze")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .padding(.leading, 100.0)
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    Text("Rows")
                        .padding(.leading, 120)
                        .font(.system(size: 20))
                    
                    Slider(value: Binding(
                            get: { Double(settings.mazeROWS) },
                            set: { settings.setROWS(Int($0)) }),
                           in: Double(MIN_MAZE_ROWS)...Double(MAX_MAZE_ROWS),
                           step: 1)
                    
                    Text(String(settings.mazeROWS))
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    Text("Columns")
                        .padding(.leading, 120)
                        .font(.system(size: 20))
                    Slider(value: Binding(
                            get: { Double(settings.mazeCOLS) },
                            set: { settings.setCOLS(Int($0)) }),
                           in: Double(MIN_MAZE_COLS)...Double(MAX_MAZE_COLS),
                           step: 1)
                    Text(String(settings.mazeCOLS))
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            
            Button("Close") {
                withAnimation {
                    stateMachine.appState = .mainMenu
                }
            }
            .padding()
        }
        .padding()
    }
}
