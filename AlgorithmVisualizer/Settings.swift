

import Foundation
class Settings: ObservableObject {
    @Published private(set) var mazeCellSize: CGFloat = 30 {
        didSet {
            if mazeCellSize < 10 { mazeCellSize = 10 } // Minimum value constraint
        }
    }

    @Published private(set) var mazeCOLS: Int = initMazeCOLS {
        didSet {
            if mazeCOLS < 1 { mazeCOLS = 1 } // Minimum value constraint
        }
    }

    @Published private(set) var mazeROWS: Int = initMazeROWS {
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

