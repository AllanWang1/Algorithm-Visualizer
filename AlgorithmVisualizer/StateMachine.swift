//
//  StateMachine.swift
//  AlgorithmVisualizer
//
//  Created by Allan Wang on 2024-11-09.
//

import Foundation
class StateMachine: ObservableObject {
    @Published var appState: AppState = .mainMenu
}
