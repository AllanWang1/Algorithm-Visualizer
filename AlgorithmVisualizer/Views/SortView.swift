import SwiftUI

struct SortView: View {
    @EnvironmentObject var stateMachine: StateMachine
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        stateMachine.appState = .mainMenu
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                Spacer()
            }
        }
    }
}
