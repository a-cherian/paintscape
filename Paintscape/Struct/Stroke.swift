//
//  Stroke.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

struct Stroke {
    var tool: String
    var tip: Tip
    var primary: RGBA32
    var secondary: RGBA32
    
    init() {
        self.tool = ""
        self.tip = Tip(type: .square, r: 2)
        self.primary = RGBA32(r: 0, g: 0, b: 0, a: 255)
        self.secondary = RGBA32(r: 255, g: 255, b: 255, a: 255)
    }
    
    init(tool: String, tip: Tip = Tip(type: .square, r: 1), primary: RGBA32 = RGBA32(), secondary: RGBA32 = RGBA32()) {
        self.tool = tool
        self.tip = tip
        if(tool == "fill") { self.tip = Tip(type: .square, r: 1) }
        self.primary = primary
        self.secondary = secondary
    }
    
    func calculatePixels(img: UnsafeMutablePointer<RGBA32>, px: Pixel, xBounds: Int, yBounds: Int) -> [Pixel] {
        if tool == "history" {
            return [px]
        }
        
        let region: [(x: Int, y: Int)] = tip.getTouchRegion(x: px.x, y: px.y)
        var pixels = [Pixel]()
        
        region.forEach { pixel in
            if pixel.x >= 0 && pixel.y >= 0 && pixel.x < xBounds && pixel.y < yBounds {
                let offset = pixel.y * xBounds + pixel.x
                let currColor = img[offset]
                
                if tool == "replace" {
                    if secondary == currColor {
                        pixels.append(Pixel(x: pixel.x, y: pixel.y, color: primary))
                    }
                }
                else if tool == "fill" {
                    pixels = floodFill(img: img, px: px, color: currColor, xBounds: xBounds, yBounds: yBounds)
                }
                else {
                    pixels.append(Pixel(x: pixel.x, y: pixel.y, color: primary))
                }
            }
        }
        
        return pixels
    }
    
    func floodFill(img: UnsafeMutablePointer<RGBA32>, px: Pixel, color: RGBA32, xBounds: Int, yBounds: Int) -> [Pixel] {
        var pixels = [Pixel]()
        var visited = [[Bool]](
         repeating: [Bool](repeating: false, count: xBounds),
         count: yBounds
        )
        var scanStack = Stack<[Int]>()
        scanStack.push([px.x, px.x, px.y, 1])
        scanStack.push([px.x, px.x, px.y - 1, -1])
        
        while(scanStack.count > 0) {
            let scan = scanStack.pop()
            var x1 = scan[0]
            let x2 = scan[1]
            let y = scan[2]
            let dy = scan[3]
            var x = x1
            if inside(x: x, y: y, color: color, xB: xBounds, yB: yBounds, img: img) && !visited[x][y] {
                while inside(x: x - 1, y: y, color: color, xB: xBounds, yB: yBounds, img: img) && !visited[x - 1][y] {
                    pixels.append(Pixel(x: x - 1, y: y, color: primary))
                    visited[x - 1][y] = true
                    x = x - 1
                }
                if x < x1 {
                    scanStack.push([x, x1 - 1, y - dy, -dy])
                }
            }
            while x1 <= x2 {
                while inside(x: x1, y: y, color: color, xB: xBounds, yB: yBounds, img: img) && !visited[x1][y] {
                    pixels.append(Pixel(x: x1, y: y, color: primary))
                    visited[x1][y] = true
                    x1 = x1 + 1
                }
                if x1 > x {
                    scanStack.push([x, x1 - 1, y + dy, dy])
                }
                if x1 - 1 > x2 {
                    scanStack.push([x2 + 1, x1 - 1, y - dy, -dy])
                }
                x1 = x1 + 1
                while x1 < x2 && !(inside(x: x1, y: y, color: color, xB: xBounds, yB: yBounds, img: img) && !visited[x1][y]) {
                    x1 = x1 + 1
                }
                x = x1
            }
        }
        
        return pixels
    }
    
    func inside(x: Int, y: Int, color: RGBA32, xB: Int, yB: Int, img: UnsafeMutablePointer<RGBA32>) -> Bool {
        let offset = y * xB + x
        let pxColor = img[offset]
        return x >= 0 && y >= 0 && x < xB && y < yB && color == pxColor
    }
    
    func floodFillSlow(img: UnsafeMutablePointer<RGBA32>, px: Pixel, color: RGBA32, xBounds: Int, yBounds: Int) -> [Pixel] {
        var pixels = [Pixel]()
//        var visited = [Pixel: Pixel]()
        var visited = [[Bool]](
         repeating: [Bool](repeating: false, count: xBounds),
         count: yBounds
        )
        var pxStack = Stack<Pixel>()
        pxStack.push(px)
        
        while(pxStack.count > 0) {
            let pt = pxStack.pop()
            if(pt.x < 0 || pt.y < 0 || pt.x >= xBounds || pt.y >= yBounds) { continue }
            let offset = pt.y * xBounds + pt.x
            let pxColor = img[offset]
            if(pxColor == color) {
                pixels.append(Pixel(x: pt.x, y: pt.y, color: primary))
                visited[pt.x][pt.y] = true
                if pt.x + 1 < xBounds && !visited[pt.x + 1][pt.y] {
                    let right = Pixel(x: pt.x + 1, y: pt.y, color: img[(pt.y) * xBounds + (pt.x + 1)])
                    visited[pt.x + 1][pt.y] = true
                    if(pxColor == color) {
                        pxStack.push(right)
                    }
                }
                if pt.x - 1 >= 0 && !visited[pt.x - 1][pt.y] {
                    let left = Pixel(x: pt.x - 1, y: pt.y, color: img[(pt.y) * xBounds + (pt.x - 1)])
                    visited[pt.x - 1][pt.y] = true
                    if(pxColor == color) {
                        pxStack.push(left)
                    }
                }
                if pt.y + 1 < yBounds && !visited[pt.x][pt.y + 1] {
                    let up = Pixel(x: pt.x, y: pt.y + 1, color: img[(pt.y + 1) * xBounds + (pt.x)])
                    visited[pt.x][pt.y + 1] = true
                    if(pxColor == color) {
                        pxStack.push(up)
                    }
                }
                if pt.y - 1 >= 0 && !visited[pt.x][pt.y - 1] {
                    let down = Pixel(x: pt.x, y: pt.y - 1, color: img[(pt.y - 1) * xBounds + (pt.x)])
                    visited[pt.x][pt.y - 1] = true
                    if(pxColor == color) {
                        pxStack.push(down)
                    }
                }
            }
        }
        
        return pixels
    }
}
