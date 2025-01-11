//
//  Settings.swift
//  AlgorithmVisualizer
//
//  Created by Allan Wang on 2025-01-07.
//

import Foundation
class Settings: ObservableObject {
    @Published private(set) var mazeCellSize: CGFloat = 30 {
        didSet {
            if mazeCellSize < 10 { mazeCellSize = 10 } // Minimum value constraint
        }
    }

    @Published private(set) var mazeCOLS: Int = 31 {
        didSet {
            if mazeCOLS < 1 { mazeCOLS = 1 } // Minimum value constraint
        }
    }

    @Published private(set) var mazeROWS: Int = 19 {
        didSet {
            if mazeROWS < 1 { mazeROWS = 1 } // Minimum value constraint
        }
    }

    func setCellSize(_ size: CGFloat) {
        mazeCellSize = size
    }

    func setCOLS(_ cols: Int) {
        mazeCOLS = cols
    }

    func setROWS(_ rows: Int) {
        mazeROWS = rows
    }
}

