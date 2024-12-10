
import SwiftUI

enum AppState {
    case mainMenu
    case maze
    case settings
}

struct ContentView: View {
    @StateObject private var stateMachine:StateMachine = StateMachine()
    var body: some View {
        switch stateMachine.appState {
        case .mainMenu:
            MainMenuView()
                .environmentObject(stateMachine)
        case .maze:
            MazeView()
                .environmentObject(stateMachine)
        case .settings:
            Text("Settings")
        }
    }
}

struct Settings {
    private var mazeCellSize: CGFloat = 30;
    private var mazeCOLS: Int = 31;
    private var mazeROWS: Int = 19;
    
    mutating func setSize(_ n: CGFloat) {
        mazeCellSize = n;
    }
    mutating func setCOLS(_ n: Int) {
        mazeCOLS = n;
    }
    mutating func setROWS(_ n: Int) {
        mazeROWS = n;
    }
    func getSize() -> CGFloat {
        return mazeCellSize;
    }
    func getCOLS() -> Int {
        return mazeCOLS;
    }
    func getROWS() -> Int {
        return mazeROWS;
    }
}

// struct for the view of the maze state. Contains all necessary functions and variables to deal with the logic components of this state
struct MazeView: View {
    @EnvironmentObject var stateMachine: StateMachine
    let square = Image(systemName:"square")
    let size: CGFloat = 30
    var COLS = 31
    var ROWS = 19
    
    @State private var colours: [[Color]]
    
    @State private var settingStart: Bool = false
    @State private var start: (Int, Int) = (-1, -1)
    @State private var settingTarget: Bool = false
    @State private var target: (Int, Int) = (-1, -1)
    @State private var settingWall = true
    
    @State private var solutionPath: [(Int, Int)] = []
    @State private var isAnimating: Bool = false
    @State private var slowAnimation: Bool = true
    
    init() {
        _colours = State(initialValue: Array(repeating: (Array(repeating: Color.white, count: ROWS)), count: COLS))
    }
    
    var body: some View {
        
        let MAPWIDTH: CGFloat = CGFloat(CGFloat(COLS) * size)
        let MAPHEIGHT: CGFloat = CGFloat(CGFloat(ROWS) * size)
                   
        ZStack {
            VStack {
                HStack {
                    Button {
                        stateMachine.appState = .mainMenu
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundStyle(.blue)
                            .padding(20)
                    }
                    Spacer()
                }
                // Maze cells
                VStack(spacing: 0) {
                    ForEach(0..<ROWS, id:\.self) { row in
                        HStack(spacing:0) {
                            ForEach(0..<COLS, id:\.self) { col in
                                
                                // each square in the grid is an individual button
                                Button {
                                    changeCell(col, row)
                                    clearSolution()
                                } label: {
                                    Rectangle()
                                        .fill(colours[col][row])
                                        .frame(width: size, height: size)
                                        .border(Color.black, width:1)
                                }
                            }
                        }
                    }
                }
                .frame(width: MAPWIDTH, height: MAPHEIGHT)
                .border(Color.black, width: 2)
                
                // Quick edit and solutions
                HStack {
                    Spacer()
                    // Editors
                    Menu {
                        
                        // set target button
                        Button {
                            settingTarget.toggle()
                            settingStart = false
                            settingWall = false
                        } label: {
                            if (settingTarget) {
                                Label("Editing Target Position...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Target Position", systemImage: "flag.checkered")
                            }
                        }
                        // set start button
                        Button {
                            settingStart.toggle()
                            settingTarget = false
                            settingWall = false
                        } label: {
                            if (settingStart) {
                                Label("Editing Start Position...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Start Position", systemImage: "mappin.and.ellipse")
                            }
                        }
                        
                        Button {
                            settingWall.toggle()
                            settingStart = false
                            settingTarget = false
                        } label: {
                            if (settingWall) {
                                Label("Editing Walls...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Walls", systemImage: "rectangle.split.3x3.fill")
                            }
                        }
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(red: 160/255, green: 153/255, blue: 1))
                                .frame(width: 100, height: 100)
                            
                            HStack {
                                Text("Editor")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: "square.and.pencil")
                            }
                            .foregroundColor(Color.black)
                        }
                    }
                    Button {
                        BFS()
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: 180, height: 100)
                                .cornerRadius(15)
                            Text("BFS")
                                .font(.title)
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    Button {
                        findPathDFS()
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: 180, height: 100)
                                .cornerRadius(15)
                            Text("DFS")
                                .font(.title)
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    Menu {
                        
                        // reset maze
                        Button {
                            clearAll()
                        } label: {
                            Label("Reset Maze", systemImage: "arrow.2.circlepath.circle")
                        }
                        // clear solution
                        Button {
                            clearSolution()
                        } label: {
                            Label("Clear Solution", systemImage: "trash.circle.fill")
                        }
                        // generate random
                        Button {
                            var newMaze: [[Color]] = Array(repeating: Array(repeating: Color.black, count: ROWS), count: COLS)
                            generateUniqueMaze(&newMaze, (1, 1))
                            colours = newMaze
                        } label: {
                            Label("Generate Maze", systemImage: "scribble.variable")
                        }
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 160/255, green: 153/255, blue: 1))
                                .frame(width: 150, height: 100)
                            
                            HStack {
                                Text("Quick Edit")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: "square.and.pencil")
                            }
                            .foregroundColor(Color.black)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Animation Mode")
                            .fontWeight(.bold)
                        HStack {
                            Button {
                                if (!slowAnimation) {
                                    clearSolution()
                                    slowAnimation = true
                                }
                            } label: {
                                slowAnimation ? Image(systemName:"checkmark.square") : Image(systemName:"square")
                            }
                            Text("Slow")
                        }
                        HStack {
                            Button {
                                if (slowAnimation) {
                                    clearSolution()
                                    slowAnimation = false
                                }
                            } label: {
                                !slowAnimation ? Image(systemName:"checkmark.square") : Image(systemName:"square")
                            }
                            Text("Fast")
                        }
                    }
                    .foregroundColor(Color.black)
                    .font(.system(size: 30))
                    Spacer()
                }
                .foregroundColor(Color(red: 152/255, green: 200/255, blue: 151/255))
                
            }
        }
        
    }
    
    /// Updates the colours 2D array. The update should be reflected on screen immediately
    ///
    /// - Parameters:
    ///     x: the x coordinate of the cell, or the first index of the colours 2D array
    ///     y: the y coordinate of the cell, or the second index of colours
    func changeCell(_ x: Int, _ y: Int) {
  
        if (settingStart) {
            if (start == (x, y)) {
                start = (-1, -1)
                colours[x][y] = Color.white
            }
            else if (target != (x, y)) {
                if (start != (-1, -1)) {
                    colours[start.0][start.1] = Color.white
                }
                colours[x][y] = Color.cyan
                start = (x, y)
            }
        }
        else if (settingTarget) {
            if (target == (x, y)) {
                target = (-1, -1)
                colours[x][y] = Color.white
            }
            else if (start != (x, y)) {
                if (target != (-1, -1)) {
                    colours[target.0][target.1] = Color.white
                }
                colours[x][y] = Color.red
                target = (x, y)
            }
        }
        else if (settingWall) {
            if (start == (x, y)) {start = (-1, -1)}
            if (target == (x, y)) {target = (-1, -1)}
            if (colours[x][y] == Color.black) {
                colours[x][y] = Color.white
            } else {
                colours[x][y] = Color.black
            }
        }
    }
    
    /// Updates maze. Argument of initial maze that is entirely made of walls is passed in at initial function call.
    ///
    /// - Parameters:
    ///     maze: a 2D array storing colours. Will be modified and final result will be the updated colours.
    ///     curr: a tuple that represents the coordinate of the current cell on the maze.
    func generateUniqueMaze(_ maze: inout [[Color]], _ curr: (Int, Int)) {
        clearAll()
        let x: Int = curr.0
        let y: Int = curr.1
        maze[x][y] = Color.white
        
        let directions = [(0, 2), (2, 0), (0, -2), (-2, 0)]
        for direction in directions.shuffled() {
            let newx = x + direction.0
            let newy = y + direction.1
            
            if (newx > 0 && newx < COLS && newy > 0 && newy < ROWS) {
                if (maze[newx][newy] == Color.black) {
                    maze[(x + newx)/2][(y + newy)/2] = Color.white
                    generateUniqueMaze(&maze, (newx, newy))
                }
            }
        }
        
    }
    
    /// Updates maze. Performs BFS if target and start are both set, and if there is no current animation running.
    /// Will start an animation if a solution is found.
    func BFS() {
        // Guard in case the start or the target has not been set yet
        guard target != (-1, -1) && start != (-1, -1) && !isAnimating
        else {noSolution()
              return}
        
        clearSolution()
        
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        var visitedPath: [(Int, Int)] = []
        
        let toVisit = Queue<(Int, Int)>()
        
        var parents = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        
        var hasSolution = false
        
        toVisit.enqueue(start)
        visited[start.0][start.1] = true
        
        while (!toVisit.isEmpty) {
            let curr: (Int, Int) = toVisit.front!
            let x = curr.0
            let y = curr.1
            if x == target.0 && y == target.1 {
                hasSolution = true
                solutionPath = backtrack(parents)
                if (slowAnimation) {
                    isAnimating = true
                    animateVisited(0, visitedPath)
                } else {
                    animateFast(visitedPath)
                }
            }
            toVisit.dequeue()
            // produce neighbours
            let neighbours: [(Int, Int)] = [(x, y + 1),
                                            (x + 1, y),
                                            (x, y - 1),
                                            (x - 1, y)]
            // if not out of bounds, wall, or visited, add to toVisit
            for point in neighbours {
                let i = point.0
                let j = point.1
                if (good(visited, point)) {
                    visited[i][j] = true
                    if (i, j) != target {visitedPath.append((i, j))}
                    parents[i][j] = (x, y)
                    toVisit.enqueue(point)
                }
            }
        }
        if (!hasSolution) {noSolution()}
    }
    
    /// - Parameters:
    ///     visited: a 2D array of Bool representing whether a cell at point in colours has been visited (if maze cell has been visited).
    ///     point: the coordinates of the cell; the indices of the cell in colours and visited.
    /// - Returns: Bool that indicates whether the cell at point should be visited.
    func good(_ visited: [[Bool]], _ point: (Int, Int)) -> Bool {
        let x = point.0
        let y = point.1
        // Check out of bounds before checking array to avoid out of bounds error.
        if 0 <= x && x < COLS && 0 <= y && y < ROWS {
            if !visited[x][y] && colours[x][y] != Color.black{
                return true
            }
        }
        return false
    }
    
    /// Updates the maze. Performs DFS is target and start are both set, and if there is no current animation running. Also updates solutionPath.
    /// Will start an animation if a solution is found.
    func findPathDFS() {
        guard start != (-1, -1) && target != (-1, -1) else {return}
        guard !isAnimating else {return}
        
        clearSolution()
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        var parents: [[(Int, Int)]] = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        var visitedPath: [(Int, Int)] = []
        visited[start.0][start.1] = true
        
        // Checks if a path could be found by traversing the maze at the start cell.
        let pathFound: Bool = DFS(start, &visited, &parents, &visitedPath)
        
        
        if pathFound {
            solutionPath = backtrack(parents)
            if (slowAnimation) {
                isAnimating = true
                animateVisited(0, visitedPath)
            } else {
                animateFast(visitedPath)
            }
        } else {
            noSolution()
        }
    }
    
    /// Updates the maze.
    ///
    /// - Parameters:
    ///     curr: tuple that represents the coordinates of the current cell
    ///     visited: 2D array of Bool that corresponds to whether each cell of the maze has been visited
    ///     parents: 2D array of tuples that records the coordinate of the parent cell of each cell of the maze
    ///     visitedPath: array of  tuples that records the order of how the cells have been visited.
    /// - Returns:Bool that indicates if the target is found during the current run of DFS.
    func DFS(_ curr: (Int, Int), _ visited: inout [[Bool]], _ parents: inout [[(Int, Int)]], _ visitedPath: inout [(Int, Int)]) -> Bool {
        if (curr == target) {return true}
        let x = curr.0
        let y = curr.1
        
        let neighbours: [(Int, Int)] = [(x, y - 1),
                                        (x + 1, y),
                                        (x, y + 1),
                                        (x - 1, y)]
        
        for pair in neighbours {
            if (good(visited, pair)) {
                let i = pair.0
                let j = pair.1
                visited[i][j] = true
                if (i, j) != target {visitedPath.append((i, j))}
                parents[i][j] = (x, y)
                // Checks if a path could be found by visiting the neighbours.
                if DFS(pair, &visited, &parents, &visitedPath) {return true}
            }
        }
        return false
    }
    
    /// - Parameters:
    ///     parents: 2D array of tuples that corresponds to the coordinate of each cell on the maze; parents[i][j] represents the parent cell of the cell (i, j).
    /// - Returns: an array of tuples that represents the path of the solution, with the target at the end of the array.
    func backtrack(_ parents:[[(Int, Int)]]) -> [(Int, Int)] {
        var path: [(Int, Int)] = []
        var curr: (Int, Int) = parents[target.0][target.1]
        while (curr != (start.0, start.1)) {
            path.insert(curr, at: 0)
            curr = parents[curr.0][curr.1]
        }
        return path
    }
    
    /// Updates colours, change colours[i][j] to purple if (i, j) is in visitedPath
    ///
    /// - Parameters:
    ///     i: the index of path to display. If i >= path.count then start animating the solution
    ///     visitedPath: the path of the visited cells, stored in order of first to last.
    func animateVisited(_ i: Int, _ visitedPath: [(Int, Int)]) {
        guard i < visitedPath.count else {animatePath(0)
            return}
        guard isAnimating else {return}
        
        let(x, y) = visitedPath[i]
        colours[x][y] = Color.purple
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            animateVisited(i + 1, visitedPath)
        }
    }
    
    /// Updates colours, change colours[i][j] to orange if (i, j) is in solutionPath.
    ///
    /// - Parameters:
    ///     i: the index of solutionPath to display.
    func animatePath(_ i: Int) {
        guard i < solutionPath.count else {isAnimating = false
            return}
        
        guard isAnimating else {return}
        
        let (x, y) = solutionPath[i]
        colours[x][y] = Color.orange
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.03) {
            animatePath(i + 1)
        }
    }
    
    /// Updates colours, change colours[i][j] to purple if (i, j) is in visited, change to orange if (i, j) is in solutionPath.
    /// The maze should be updated almost immediately, as asynchronous programming has not been implemented here.
    ///
    /// - Parameters:
    ///     visited: array of tuples that represents the cells that have been visited.
    func animateFast(_ visited: [(Int, Int)]) {
        for cord in visited {
            colours[cord.0][cord.1] = Color.purple
        }
        for cord in solutionPath {
            colours[cord.0][cord.1] = Color.orange
        }
    }
    
    
    func noSolution() {
        
    }
    
    /// Updates colours. Stop animation immediately, change colours[i][j] to white if (i, j) is not a wall, the start, or the target.
    func clearSolution() {
        solutionPath = []
        isAnimating = false
        for x in 0..<COLS {
            for y in 0..<ROWS {
                if (colours[x][y] != Color.black && start != (x, y) && target != (x, y)) {
                    colours[x][y] = Color.white
                }
            }
        }
    }
    
    /// Updates the entire maze. Resets all the state variables to their default values.
    func clearAll() {
        solutionPath = []
        isAnimating = false
        settingStart = false
        start = (-1, -1)
        settingTarget = false
        target = (-1, -1)
        colours = Array(repeating: Array(repeating: Color.white, count: ROWS), count: COLS)
    }
}

struct MainMenuView: View {
    @EnvironmentObject var stateMachine: StateMachine
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Algorithm Visualizer")
                .font(.system(size: 50))
                .fontWeight(.heavy)
                .foregroundColor(Color.blue)
            Spacer()
            VStack {
                Button {
                    // Sorting algorithms
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
                    
                } label: {
                    
                }
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

#Preview {
    ContentView()
}
