//
//  Stroke.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

import UIKit

enum Tool {
    case brush
    case fill
    case spraycan
    case eyedropper
    case none
}

enum DrawMode {
    case draw
    case replace
    case exclude
}

struct Stroke {
    var tool: Tool
    var tip: Tip
    var primary: RGBA32
    var secondary: RGBA32
    var drawMode: DrawMode
    var tipImage: UIImage
    
    init(tool: Tool = .brush, tip: Tip = Tip(type: .square, r: 1), primary: RGBA32 = RGBA32(), secondary: RGBA32 = RGBA32(), drawMode: DrawMode = .draw) {
        self.tool = tool
        self.tip = tip
        self.primary = primary
        self.secondary = secondary
        self.drawMode = drawMode
        self.tipImage = UIImage()
        self.tipImage = getTipImage()
    }
    
    func getTipImage() -> UIImage {
        let area = tip.getTipRegion()
        
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = tip.width
        let height           = tip.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return UIImage()
        }
        context.interpolationQuality = .none

        guard let buffer = context.data else {
            return UIImage()
        }
        

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        area.forEach { pixel in
            let offset = pixel.y * width + pixel.x
            pixelBuffer[offset] = primary
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: 1, orientation: .up)
        
        return outputImage
    }
}
