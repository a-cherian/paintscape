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
        self.tip = Tip(type: .square, r: 1)
        self.primary = RGBA32(r: 0, g: 0, b: 0, a: 255)
        self.secondary = RGBA32(r: 255, g: 255, b: 255, a: 255)
    }
    
    init(tool: String, tip: Tip = Tip(type: .square, r: 1), primary: RGBA32 = RGBA32(), secondary: RGBA32 = RGBA32()) {
        self.tool = tool
        self.tip = tip
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
                else {
                    pixels.append(Pixel(x: pixel.x, y: pixel.y, color: primary))
                }
            }
        }
        
        return pixels
    }
}
