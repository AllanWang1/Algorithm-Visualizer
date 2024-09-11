
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
        
        
    }
}



#Preview {
    ContentView()
}
