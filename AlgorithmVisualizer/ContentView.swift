
import SwiftUI

struct ContentView: View {
    let square = Image(systemName:"square")
    let size: CGFloat = 25
    var COLS = 47
    var ROWS = 25
    
    @State private var colours: [[Color]]
    
    @State var settingStart:Bool = false
    @State var start: (Int, Int) = (-1, -1)
    @State var settingTarget:Bool = false
    @State var target: (Int, Int) = (-1, -1)
    @State var solutionPath: [(Int, Int)] = []
    @State var isAnimating = false
    
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
                                    changeWall(col, row)
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
                        // set start button
                        Button {
                            settingStart.toggle()
                            if (settingTarget) {
                                settingTarget = false
                            }
                        } label: {
                            if (settingStart) {
                                Label("Editing Start Position...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Start Position", systemImage: "mappin.and.ellipse")
                            }
                        }
                        
                        // set target button
                        Button {
                            settingTarget.toggle()
                            if (settingStart) {
                                settingStart = false
                            }
                        } label: {
                            if (settingTarget) {
                                Label("Editing Target Position...", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Edit Target Position", systemImage: "flag.checkered")
                            }
                        }
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(red: 160/255, green: 153/255, blue: 1))
                                .frame(width: 100, height: 100)
                            Text("Editor")
                                .font(.title2)
                                .fontWeight(.bold)
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
                        var newMaze: [[Color]] = Array(repeating: Array(repeating: Color.black, count: ROWS), count: COLS)
                        generateUniqueMaze(&newMaze, (1, 1))
                        //knockWalls(&newMaze)
                        colours = newMaze
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: 180, height: 70)
                                .cornerRadius(15)
                            Text("Generate \nUnique Maze")
                                .font(.title)
                                .foregroundColor(Color.black)
                        }
                        .foregroundColor(Color(red: 255/255, green: 200/255, blue: 150/255))
                    }
                    
                    Button {
                        clearSolution()
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: 180, height: 70)
                                .cornerRadius(15)
                            Text("Clear Solution")
                                .font(.title)
                                .foregroundColor(Color.black)
                        }
                        .foregroundColor(Color(red: 255/255, green: 200/255, blue: 150/255))
                    }
                    Button {
                        clearAll()
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: 180, height: 70)
                                .cornerRadius(15)
                            Text("Reset Maze")
                                .font(.title)
                                .foregroundColor(Color.black)
                        }
                        .foregroundColor(Color(red: 255/255, green: 200/255, blue: 150/255))
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
                    Spacer()
                }
                .foregroundColor(Color(red: 152/255, green: 200/255, blue: 151/255))
                
            }
        }
        
    }
    func changeWall(_ x: Int, _ y: Int) {
        
        if (settingStart) {
            if (target != (x, y)) {
                if (start != (-1, -1)) {
                    colours[start.0][start.1] = Color.white
                }
                colours[x][y] = Color.cyan
                start = (x, y)
            }
        }
        else if (settingTarget) {
            if (start != (x, y)) {
                if (target != (-1, -1)) {
                    colours[target.0][target.1] = Color.white
                }
                colours[x][y] = Color.red
                target = (x, y)
            }
        }
        
        else if (colours[x][y] == Color.black) {
            // deal with start and target blocks
            if (start == (x, y)) {start = (-1, -1)}
            if (target == (x, y)) {target = (-1, -1)}
            colours[x][y] = Color.white
        } else {
            // deal with start and target blocks
            if (start == (x, y)) {start = (-1, -1)}
            if (target == (x, y)) {target = (-1, -1)}
            colours[x][y] = Color.black
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
    
    func knockWalls(_ maze: inout [[Color]]) {
//        if (COLS * ROWS < 100) {
//            return
//        }
//        var total = COLS * ROWS
//        var p = 0.33
//        var n = 10
//        while (n > 0 && total > 0) {
//            let randomValue = Double.random(in: 0...1)
//            if (randomValue < p) {
//
//            }
//        }
    }
    
    
    func BFS() {
        // Guard in case the start or the target has not been set yet
        guard target != (-1, -1) && start != (-1, -1) && !isAnimating else {return}
        
        clearSolution()
        
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: ROWS), count: COLS)
        
        let toVisit = Queue<(Int, Int)>()
        
        var parents = Array(repeating: Array(repeating: (-1, -1), count: ROWS), count: COLS)
        
        toVisit.enqueue(start)
        visited[start.0][start.1] = true
        
        while (!toVisit.isEmpty) {
            let curr: (Int, Int) = toVisit.front!
            let x = curr.0
            let y = curr.1
            if x == target.0 && y == target.1 {
                print("found target")
                solutionPath = backtrack(parents)
                isAnimating = true
                animatePath(0)
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
                    if (i != target.0 || j != target.1) {colours[i][j] = Color.purple}
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
        
        visited[start.0][start.1] = true
        
        let pathFound: Bool = DFS(start, &visited, &parents)
        
        
        if pathFound {
            solutionPath = backtrack(parents)
            isAnimating = true
            animatePath(0)
        }
    }
    
    func DFS(_ curr: (Int, Int), _ visited: inout [[Bool]], _ parents: inout [[(Int, Int)]]) -> Bool {
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
                parents[i][j] = (x, y)
                if (i != target.0 || j != target.1) {colours[i][j] = Color.purple}
                if DFS(pair, &visited, &parents) {return true}
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



#Preview {
    ContentView()
}
