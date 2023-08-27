//
//  History.swift
//  Paintscape
//
//  Created by AC on 8/19/23.
//

import UIKit

// https://medium.com/devslopes-blog/swift-data-structures-stack-4f301e4fa0dc
struct History {
    var history: [[Pixel]] = []
    var maxItems = 50
    var current = -1
    
    init(maxItems: Int = 50) {
        self.history = []
        self.maxItems = maxItems
    }
    
    mutating func add(action: [Pixel]) {
        wipeAfterCurrent()
        
        if history.count >= maxItems {
            history.remove(at: 0)
            current -= 1
        }
        history.append(action)
        
        current += 1
    }
    
    mutating func undo(image: UIImage, width: Int, height: Int) -> [Pixel] {
        if current < 0 { return [] }
        
        guard let inputCGImage = image.cgImage else {
            return []
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return []
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else {
            return []
        }

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        let pixels = history[current]
        var replaced = [Pixel]()
        
        pixels.forEach { pixel in
            if pixel.x > 0 && pixel.y > 0 && pixel.x < width && pixel.y < height {
                let offset = pixel.y * width + pixel.x
                replaced.append(Pixel(x: pixel.x, y: pixel.y, color: pixelBuffer[offset]))
            }
        }
        
        history[current] = replaced
        current -= 1
        
        return pixels
    }
    
    mutating func redo(image: UIImage, width: Int, height: Int) -> [Pixel] {
        if current == history.count - 1 { return [] }
        current += 1

        guard let inputCGImage = image.cgImage else {
            return []
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return []
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else {
            return []
        }

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        let pixels = history[current]
        var replaced = [Pixel]()
        pixels.forEach { pixel in
            if pixel.x > 0 && pixel.y > 0 && pixel.x < width && pixel.y < height {
                let offset = pixel.y * width + pixel.x
                replaced.append(Pixel(x: pixel.x, y: pixel.y, color: pixelBuffer[offset]))
            }
        }
        
        history[current] = replaced
        
        return pixels
    }
    
    mutating func wipeAfterCurrent() {
        if history.count == current + 1 { return }
        
        for i in (current + 1...history.count - 1).reversed() {
            history.remove(at: i)
        }
    }
}
