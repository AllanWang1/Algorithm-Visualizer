import Foundation

enum AppState {
    case mainMenu
    case maze
    case sort
    case settings
}


// MazeView
let initMazeCellSize: CGFloat = 30
let initMazeCOLS: Int = 27
let initMazeROWS: Int = 15

// Settings
let MAX_MAZE_COLS: Int = 37
let MAX_MAZE_ROWS: Int = 21
let MIN_MAZE_COLS: Int = 4
let MIN_MAZE_ROWS: Int = 4
