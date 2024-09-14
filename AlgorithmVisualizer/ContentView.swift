
import SwiftUI

struct ContentView: View {
    let square = Image(systemName:"square")
    let size: CGFloat = 30
    var COLS = 30
    var ROWS = 20
    @State private var colours: [[Color]]
    
    @State var settingStart:Bool = false
    @State var start: [Int] = []
    @State var settingTarget:Bool = false
    @State var target: [Int] = []
    
    init() {
        _colours = State(initialValue: Array(repeating: (Array(repeating: Color.white, count: COLS)), count: ROWS))
    }
    
    var body: some View {
        
        let MAPWIDTH: CGFloat = CGFloat(CGFloat(COLS) * size)
        let MAPHEIGHT: CGFloat = CGFloat(CGFloat(ROWS) * size)
                   
        
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                ForEach(0..<ROWS, id:\.self) { col in
                    HStack(spacing:0) {
                        ForEach(0..<COLS, id:\.self) { row in
                            
                            // each square in the grid is an individual button
                            Button {
                                changeWall(col, row, &colours)
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
            // set start button
            Button {
                settingStart = !settingStart
                if (settingTarget) {
                    settingTarget = false
                }
            } label: {
                if (settingStart) {
                    Text("Setting Start Position...")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                } else {
                    Text("Set Start Position")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                }
            }
            // set target button
            Button {
                settingTarget = !settingTarget
                if (settingStart) {
                    settingStart = false
                }
            } label: {
                if (settingTarget) {
                    Text("Setting Target Position...")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                } else {
                    Text("Set Target Position")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                }
            }
            
            
            HStack {
                Spacer()
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
                
                Spacer()
                
                Button {
                    
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
            
            
            Spacer()
        }
        
    }
    func changeWall(_ x: Int, _ y: Int, _ colours: inout [[Color]]) {
        if (settingStart) {
            if (target != [x, y]) {
                if (start.count != 0) {
                    colours[start[0]][start[1]] = Color.white
                }
                colours[x][y] = Color.cyan
                start = [x, y]
            }
        }
        else if (settingTarget) {
            if (start != [x, y]) {
                if (target.count != 0) {
                    colours[target[0]][target[1]] = Color.white
                }
                colours[x][y] = Color.red
                target = [x, y]
            }
        }
        
        else if (colours[x][y] == Color.white) {
            // deal with start and target blocks
            if (start == [x, y]) {start = []}
            if (target == [x, y]) {target = []}
            colours[x][y] = Color.black
        } else {
            // deal with start and target blocks
            if (start == [x, y]) {start = []}
            if (target == [x, y]) {target = []}
            colours[x][y] = Color.white
        }
    }
    
    func BFS() {
        // Guard in case the start or the target has not been set yet
        if (target.count != 2 || start.count != 2) {
            return
        }
        var delayInSeconds = 0.05
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: COLS), count: ROWS)
        
        var toVisit = Queue<[Int]>()
        
        var parents = Array(repeating: Array(repeating: (-1, -1), count: COLS), count: ROWS)
        
        toVisit.enqueue(start)
        visited[start[0]][start[1]] = true
        
        while (!toVisit.isEmpty) {
            let curr: [Int] = toVisit.front!
            let x = curr[1]
            let y = curr[0]
            if x == target[1] && y == target[0] {
                print("found target")
                backtrack(parents)
                //print(String(x) + ", " + String(y))
                break
            }
            toVisit.dequeue()
            // produce neighbours
            let neighbours: [[Int]] = [[y + 1, x],
                                       [y - 1, x],
                                       [y, x + 1],
                                       [y, x - 1]]
            // if not out of bounds, wall, or visited, add to toVisit
            for point in neighbours {
                let i = point[0]
                let j = point[1]
                if (good(visited, point)) {
                    visited[i][j] = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
//                        if (i != target[0] || j != target[1]) {colours[i][j] = Color.purple}
//                        
//                    }
                    if (i != target[0] || j != target[1]) {colours[i][j] = Color.purple}
                    parents[i][j] = (x, y)
                    delayInSeconds += 0.01
                    toVisit.enqueue(point)
                }
            }
        }
    }
    
    func good(_ visited: [[Bool]], _ point: [Int]) -> Bool {
        let x = point[1]
        let y = point[0]
        // Check out of bounds before checking array to avoid out of bounds error.
        if 0 <= x && x < COLS && 0 <= y && y < ROWS {
            if !visited[y][x] && colours[y][x] != Color.black{
                return true
            }
        }
        return false
    }
    
    func backtrack(_ parents:[[(Int, Int)]]) {
        for row in parents {
            for pair in row {
                if pair != (-1, -1) {
                    print(String(pair.0) + ", " + String(pair.1))
                }
                
            }
        }
        var path: [(Int, Int)] = []
        var curr: (Int, Int) = parents[target[0]][target[1]]
        while (curr != (start[1], start[0])) {
            path.insert(curr, at: 0)
            print(String(curr.1) + ", " + String(curr.0))
            curr = parents[curr.1][curr.0]
        }
        for cord in path {
            colours[cord.1][cord.0] = Color.orange
        }
    }
}



#Preview {
    ContentView()
}
