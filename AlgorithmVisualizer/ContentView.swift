
import SwiftUI

struct ContentView: View {
    let square = Image(systemName:"square")
    let size: CGFloat = 30
    var COLS = 10
    var ROWS = 5
    @State private var colours: [[Color]]
    
    init() {
        _colours = State(initialValue: Array(repeating: (Array(repeating: Color.white, count: COLS)), count: ROWS))
    }
    
    var body: some View {
        
        let MAPWIDTH: CGFloat = CGFloat(CGFloat(COLS) * size)
        let MAPHEIGHT: CGFloat = CGFloat(CGFloat(ROWS) * size)
                   
        
        VStack {
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
        }
        .frame(width: MAPWIDTH, height: MAPHEIGHT)
        .border(Color.black, width: 2)
        
    }
    func changeWall(_ x: Int, _ y: Int, _ colours: inout [[Color]]) {
        colours[x][y] = Color.black
    }
}



#Preview {
    ContentView()
}
