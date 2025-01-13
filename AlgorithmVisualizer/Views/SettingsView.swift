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
                           in: 2...25,
                           step: 1)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                HStack {
                    Text("Columns")
                        .padding(.leading, 120)
                        .font(.system(size: 20))
                    Slider(value: Binding(
                            get: { Double(settings.mazeCOLS) },
                            set: { settings.setCOLS(Int($0)) }),
                           in: 2...40,
                           step: 1)
                    Spacer()
                }
                .padding(.bottom, 8)
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
