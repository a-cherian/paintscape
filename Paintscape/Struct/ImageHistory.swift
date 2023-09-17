//
//  History.swift
//  Paintscape
//
//  Created by AC on 8/19/23.
//

import UIKit

// https://medium.com/devslopes-blog/swift-data-structures-stack-4f301e4fa0dc
struct ImageHistory {
    var history: [UIImage] = []
    var maxItems = 50
    var current = -1
    
    init(maxItems: Int = 50) {
        self.history = []
        self.maxItems = maxItems
    }
    
    mutating func add(image: UIImage) {
        wipeAfterCurrent()
        
        if history.count >= maxItems {
            history.remove(at: 0)
            current -= 1
        }
        history.append(image)
        
        current += 1
    }
    
    mutating func undo(image: UIImage) -> UIImage? {
        if current < 0 { return nil }
        
        let returnedImage = history[current]
        history[current] = image
        current -= 1
        
        return returnedImage
    }
    
    mutating func redo(image: UIImage) -> UIImage? {
        if current == history.count - 1 { return nil }
        current += 1
        
        let returnedImage = history[current]
        history[current] = image
        
        return returnedImage
    }
    
    mutating func wipeAfterCurrent() {
        if history.count == current + 1 { return }
        
        for i in (current + 1...history.count - 1).reversed() {
            history.remove(at: i)
        }
    }
}
