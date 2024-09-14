

import Foundation
class Queue<T> {
    private var elements: [T] = []
    
    // append into the end of the queue
    func enqueue(_ element: T) {
        elements.append(element)
    }
    
    func dequeue() {
        elements.removeFirst()
    }
    
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    var front: T?{
        return elements.first
    }
    
    var count: Int {
        return elements.count
    }
}
