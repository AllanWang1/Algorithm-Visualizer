import SwiftUI

private class Action: ObservableObject {
    @Published var editingStart: Bool = false
    @Published var editingTarget: Bool = false
    @Published var editingWall: Bool = true
    @Published var isAnimating: Bool = false
    @Published var slowAnimation: Bool = false
    @Published var noSolution: Bool = false
    
    func settingStart() {
        self.editingStart = true
        self.editingTarget = false
        self.editingWall = false
    }
    func settingTarget() {
        self.editingStart = false
        self.editingTarget = true
        self.editingWall = false
    }
    func reset() {
        self.editingStart = false
        self.editingTarget = false
        self.editingWall = true
    }
}

private class Maze: ObservableObject {
    @Published var start: (Int, Int) = (-1 , -1)
    @Published var target: (Int, Int) = (-1, -1)
}


// struct for the view of the maze state. Contains all necessary functions and variables to deal with the logic components of this state
struct MazeView: View {
    @EnvironmentObject var stateMachine: StateMachine
    @EnvironmentObject var settings: Settings
    
    // Properties are based on settings.
    private let COLS: Int
    private let ROWS: Int
    private let size: CGFloat
    
    @State private var colours: [[Color]]

    // Class type -> instances are objects
    @StateObject private var action: Action = Action()
    @StateObject private var maze: Maze = Maze()
    
    
    @State private var solutionPath: [(Int, Int)] = []
    
    init (_ x: Int, _ y: Int, _ s: CGFloat) {
        colours = Array(repeating: Array(repeating: Color.white, count: y), count: x)
        COLS = x
        ROWS = y
        size = s
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
                            action.settingTarget()
                        } label: {
                            if (action.editingTarget) {
                                Label("Editing Target Position...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Target Position", systemImage: "flag.checkered")
                            }
                        }
                        // set start button
                        Button {
                            action.settingStart()
                        } label: {
                            if (action.editingStart) {
                                Label("Editing Start Position...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Start Position", systemImage: "mappin.and.ellipse")
                            }
                        }
                        
                        Button {
                            action.reset()
                        } label: {
                            if (action.editingWall) {
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
                    
                    // Quick Edit
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
                                if (!action.slowAnimation) {
                                    clearSolution()
                                    action.slowAnimation = true
                                }
                            } label: {
                                action.slowAnimation ? Image(systemName:"checkmark.square") : Image(systemName:"square")
                            }
                            Text("Slow")
                        }
                        HStack {
                            Button {
                                if (action.slowAnimation) {
                                    clearSolution()
                                    action.slowAnimation = false
                                }
                            } label: {
                                !action.slowAnimation ? Image(systemName:"checkmark.square") : Image(systemName:"square")
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
            if (action.noSolution) {
                ZStack {
                    Color.gray.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                action.noSolution = false
                            }
                        }
                    
                    //ultraThinMaterial will blur what is behind the warning
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(red: 211/255, green: 211/255, blue: 211/255))
                        .frame(maxWidth: 700, maxHeight: 500)
                        .background(.ultraThinMaterial)
                        .shadow(radius: 10)
                        .transition(.scale)
                    
                    VStack {
                        VStack {
                            Text("A solvable maze has a start, exit, and a path between them.")
                            Text("This maze has no solution due to: ")
                            if (maze.target == (-1, -1)) {
                                Text("- No exit (target) is set")
                            }
                            if (maze.start == (-1, -1)) {
                                Text("- No start position is set")
                            }
                            if (maze.start != (-1, -1) && maze.target != (-1, -1)) {
                                Text("- No possible path between start and exit (target)")
                            }
                        }
                        .foregroundStyle(Color.black)
                        .font(.system(size: 25))
                        
                        HStack {
                            Spacer()
                            Button{
                                withAnimation {
                                    action.noSolution = false
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(Color(red: 1, green: 213/255, blue: 128/255))
                                        .frame(width: 150, height: 80)
                                    Text("Got it, thanks")
                                        .foregroundStyle(Color.white)
                                        
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        } // main ZStack 
        
    }
    
    /// Updates the colours 2D array. The update should be reflected on screen immediately
    ///
    /// - Parameters:
    ///     x: the x coordinate of the cell, or the first index of the colours 2D array
    ///     y: the y coordinate of the cell, or the second index of colours
    func changeCell(_ x: Int, _ y: Int) {
  
        if (action.editingStart) {
            if (maze.start == (x, y)) {
                maze.start = (-1, -1)
                colours[x][y] = Color.white
            }
            else if (maze.target != (x, y)) {
                if (maze.start != (-1, -1)) {
                    colours[maze.start.0][maze.start.1] = Color.white
                }
                colours[x][y] = Color.cyan
                maze.start = (x, y)
            }
        }
        else if (action.editingTarget) {
            if (maze.target == (x, y)) {
                maze.target = (-1, -1)
                colours[x][y] = Color.white
            }
            else if (maze.start != (x, y)) {
                if (maze.target != (-1, -1)) {
                    colours[maze.target.0][maze.target.1] = Color.white
                }
                colours[x][y] = Color.red
                maze.target = (x, y)
            }
        }
        else if (action.editingWall) {
            if (maze.start == (x, y)) {maze.start = (-1, -1)}
            if (maze.target == (x, y)) {maze.target = (-1, -1)}
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
        guard maze.target != (-1, -1) && maze.start != (-1, -1) && !action.isAnimating
        else {noSolution()
              return}
        
        clearSolution()
        
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        var visitedPath: [(Int, Int)] = []
        
        let toVisit = Queue<(Int, Int)>()
        
        var parents = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        
        var hasSolution = false
        
        toVisit.enqueue(maze.start)
        visited[maze.start.0][maze.start.1] = true
        
        while (!toVisit.isEmpty) {
            let curr: (Int, Int) = toVisit.front!
            let x = curr.0
            let y = curr.1
            if x == maze.target.0 && y == maze.target.1 {
                hasSolution = true
                solutionPath = backtrack(parents)
                if (action.slowAnimation) {
                    action.isAnimating = true
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
                    if (i, j) != maze.target {visitedPath.append((i, j))}
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
        guard maze.start != (-1, -1) && maze.target != (-1, -1) else {return}
        guard !action.isAnimating else {return}
        
        clearSolution()
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        var parents: [[(Int, Int)]] = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        var visitedPath: [(Int, Int)] = []
        visited[maze.start.0][maze.start.1] = true
        
        // Checks if a path could be found by traversing the maze at the start cell.
        let pathFound: Bool = DFS(maze.start, &visited, &parents, &visitedPath)
        
        
        if pathFound {
            solutionPath = backtrack(parents)
            if (action.slowAnimation) {
                action.isAnimating = true
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
        if (curr == maze.target) {return true}
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
                if (i, j) != maze.target {visitedPath.append((i, j))}
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
        var curr: (Int, Int) = parents[maze.target.0][maze.target.1]
        while (curr != (maze.start.0, maze.start.1)) {
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
        guard action.isAnimating else {return}
        
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
        guard i < solutionPath.count else {action.isAnimating = false
            return}
        
        guard action.isAnimating else {return}
        
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
    
    /// Sets action.noSolution = true. May add more features in future.
    func noSolution() {
        withAnimation {
            action.noSolution = true
        }
    }
    
    /// Updates colours. Stop animation immediately, change colours[i][j] to white if (i, j) is not a wall, the start, or the target.
    func clearSolution() {
        solutionPath = []
        action.isAnimating = false
        for x in 0..<COLS {
            for y in 0..<ROWS {
                if (colours[x][y] != Color.black && maze.start != (x, y) && maze.target != (x, y)) {
                    colours[x][y] = Color.white
                }
            }
        }
    }
    
    /// Updates the entire maze. Resets all the state variables to their default values.
    func clearAll() {
        solutionPath = []
        action.reset()
        maze.start = (-1, -1)
        maze.target = (-1, -1)
        colours = Array(repeating: Array(repeating: Color.white, count: ROWS), count: COLS)
    }
    
}
