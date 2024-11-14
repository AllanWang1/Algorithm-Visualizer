
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
struct MazeView: View {
    let square = Image(systemName:"square")
    let size: CGFloat = 25
    var COLS = 47
    var ROWS = 25
    
    @State private var colours: [[Color]]
    
    @State var settingStart:Bool = false
    @State var start: (Int, Int) = (-1, -1)
    @State var settingTarget:Bool = false
    @State var target: (Int, Int) = (-1, -1)
    @State var settingWall = true
    @State var solutionPath: [(Int, Int)] = []
    @State var isAnimating: Bool = false
    @State var slowAnimation: Bool = true
    
    init() {
        _colours = State(initialValue: Array(repeating: (Array(repeating: Color.white, count: ROWS)), count: COLS))
    }
    
    var body: some View {
        
        let MAPWIDTH: CGFloat = CGFloat(CGFloat(COLS) * size)
        let MAPHEIGHT: CGFloat = CGFloat(CGFloat(ROWS) * size)
                   
        ZStack {
            VStack {
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
    
    //var newMaze: [[Color]] = Array(repeating: Array(repeating: Color.black, count: ROWS), count: COLS)
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
    
    func BFS() {
        // Guard in case the start or the target has not been set yet
        guard target != (-1, -1) && start != (-1, -1) && !isAnimating else {return}
        
        clearSolution()
        
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        var visitedPath: [(Int, Int)] = []
        
        let toVisit = Queue<(Int, Int)>()
        
        var parents = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        
        toVisit.enqueue(start)
        visited[start.0][start.1] = true
        
        while (!toVisit.isEmpty) {
            let curr: (Int, Int) = toVisit.front!
            let x = curr.0
            let y = curr.1
            if x == target.0 && y == target.1 {
                solutionPath = backtrack(parents)
                if (slowAnimation) {
                    isAnimating = true
                    animateVisited(0, visitedPath)
                } else {
                    animateFast(visitedPath)
                }
                break
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
        noSolution()
    }
    
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
    
    func findPathDFS() {
        guard start != (-1, -1) && target != (-1, -1) else {return}
        guard !isAnimating else {return}
        
        clearSolution()
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        var parents: [[(Int, Int)]] = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        var visitedPath: [(Int, Int)] = []
        visited[start.0][start.1] = true
        
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
                if DFS(pair, &visited, &parents, &visitedPath) {return true}
            }
        }
        return false
    }
    
    func backtrack(_ parents:[[(Int, Int)]]) -> [(Int, Int)] {
        var path: [(Int, Int)] = []
        var curr: (Int, Int) = parents[target.0][target.1]
        while (curr != (start.0, start.1)) {
            path.insert(curr, at: 0)
            curr = parents[curr.0][curr.1]
        }
        return path
    }
    
    func animateVisited(_ i: Int, _ path: [(Int, Int)]) {
        guard i < path.count else {animatePath(0)
            return}
        guard isAnimating else {return}
        
        let(x, y) = path[i]
        colours[x][y] = Color.purple
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            animateVisited(i + 1, path)
        }
    }
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
            Text("Welcome to Algorithm Visualizer")
                .font(.system(size: 50))
                .fontWeight(.heavy)
                .foregroundColor(Color.blue)
            HStack {
                Spacer()
                Button {
                    stateMachine.appState = .maze
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Color.teal)
                            .frame(width: 400, height: 150)
                        Text("BFS and DFS on a Maze")
                            .font(.system(size: 24))
                            .fontWeight(.black)
                            .foregroundStyle(Color.white)
                    }
                }
                Spacer()
            }
                
        }
    }
}


#Preview {
    ContentView()
}
