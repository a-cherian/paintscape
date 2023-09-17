//
//  CanvasView.swift
//  Paintscape
//
//  Created by AC on 8/16/23.
//

import UIKit
import SwiftUI

protocol CanvasViewDelegate: AnyObject {
    func didColorChange(_ color: RGBA32)
}

class CanvasView: UIView {
    weak var delegate: CanvasViewDelegate?
    var movementEnabled = false
    var stroke = Stroke()
    var replaceMask: UIImage? = UIImage()
    let imageView = UIImageView()
    private lazy var previousTouchPoint = CGPoint.zero
    var touchPoints = [Pixel]()
    var centers = [Pixel]()
    var points = [Pixel]()
    var history = ImageHistory(maxItems: 50)
    var magnifyingGlass = MagnifyingGlassView()
    var xBounds = 200
    var yBounds = 200
    var context = CGContext(data: nil, width: 200, height: 200, bitsPerComponent: 8, bytesPerRow: 800, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: RGBA32.bitmapInfo)
    
    override init(frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200))) {
        super.init(frame: frame)
        if frame.size.height == 0 || frame.size.width == 0 { return }
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        contentMode = UIView.ContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        imageView.layer.magnificationFilter = CALayerContentsFilter.nearest
        addSubview(imageView)
        
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        layoutIfNeeded()
        
        let size = CGSize(width: imageView.bounds.size.width, height: imageView.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), true, 1);
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.white.cgColor)
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        let img = UIGraphicsGetImageFromCurrentImageContext() ??  UIImage();
        UIGraphicsEndImageContext();
        
        xBounds = Int(size.width)
        yBounds = Int(size.height)
        
        imageView.image = img
        imageView.setNeedsDisplay()
        generateContext()
        
        magnifyingGlass = MagnifyingGlassView(offset: CGPoint.zero,
                                              radius: 30.0,
                                              scale: 2.0,
                                              borderColor: UIColor.lightGray,
                                              borderWidth: 3.0,
                                              showsCrosshair: true,
                                              crosshairColor: UIColor.lightGray,
                                              crosshairWidth: 0.5)
        
        layer.magnificationFilter = CALayerContentsFilter.nearest
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func undo() {
        if let img = history.undo(image: imageView.image!) {
            imageView.image = img
            refreshContext()
        }
        setNeedsDisplay()
    }
    
    func redo() {
        if let img = history.redo(image: imageView.image!) {
            imageView.image = img
            refreshContext()
        }
        setNeedsDisplay()
    }
    
    func eyedropper(location: CGPoint) {
        guard let pixel = Pixel(point: location, view: imageView, color: RGBA32()) else { return }
        
        delegate?.didColorChange(imageView.image!.getPixel(pixel: pixel))
    }
    
    // https://stackoverflow.com/questions/31661023/change-color-of-certain-pixels-in-a-uiimage
    func changePixels(pixels: [Pixel], history: Bool = false) -> UIImage? {
        let image = imageView.image!
        guard let inputCGImage = image.cgImage else {
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        pixels.forEach { pixel in
            let offset = pixel.y * xBounds + pixel.x
            pixelBuffer[offset] = pixel.color
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        centers = [Pixel]()
        points = [Pixel]()
        
        return outputImage
    }
    
    // https://stackoverflow.com/questions/31661023/change-color-of-certain-pixels-in-a-uiimage
    func getPixel(in image: UIImage, pixel: Pixel) -> RGBA32 {
        guard let inputCGImage = image.cgImage else {
            return RGBA32()
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return RGBA32()
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            return RGBA32()
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        if pixel.x > 0 && pixel.y > 0 && pixel.x < xBounds && pixel.y < yBounds {
            let offset = pixel.y * xBounds + pixel.x
            let currColor = pixelBuffer[offset]
            return currColor
        }
        
        return RGBA32()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(movementEnabled || stroke.tool == .eyedropper) { return }
        
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        if let pixel = Pixel(point: point, view: imageView, color: RGBA32(r: 255, g: 0, b: 0, a: 255)) {
            history.add(image: imageView.image!)
            if stroke.tool == .fill {
                centers.append(pixel)
                fillStrokeRegion()
                refreshContext()
            }
            else {
                if stroke.tool == .replace, let mask = replaceMask?.cgImage {
                    context?.saveGState()
                    context?.clip(to: CGRect(x: 0, y: 0, width: xBounds, height: yBounds), mask: mask)
                }
                imageView.image = drawTip(x: pixel.x, y: pixel.y) ?? imageView.image
                touchPoints.append(pixel)
            }
        }
        setNeedsDisplay()
    }
    
    func drawTip(x: Int, y: Int) -> UIImage? {
        guard let tipCGImage = stroke.tipImage.cgImage else { return nil }
        guard let img = imageView.image else { return nil }
        context?.interpolationQuality = .none
        
        let tipWidth = stroke.tipImage.size.width
        let tipHeight = stroke.tipImage.size.height
        let offset = stroke.tip.width % 2 == 0 ? 0 : -0.5
        context?.draw(tipCGImage, in: CGRect(x: CGFloat(x) - tipWidth / 2 + offset, y: CGFloat(yBounds - y) - tipHeight / 2 + offset, width: tipWidth, height: tipHeight))
        
        guard let outputCGImage = context?.makeImage() else {
            return nil
        }
        let outputImage = UIImage(cgImage: outputCGImage, scale: img.scale, orientation: img.imageOrientation)
        
        centers = [Pixel]()
        points = [Pixel]()
        
        return outputImage
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(movementEnabled || stroke.tool == .eyedropper || stroke.tool == .fill) { return }
        
        super.touchesMoved(touches, with: event)
        touches.forEach { touch in
            if let coalescedTouches = event?.coalescedTouches(for: touch) {
                coalescedTouches.forEach { coalescedTouch in
                    if let pixel = Pixel(point: coalescedTouch.location(in: self), view: imageView, color: stroke.primary) {
                        touchPoints.append(pixel)
                        centers.append(pixel)
                    }
                }
            } else {
                if let pixel = Pixel(point: touch.location(in: self), view: imageView, color: stroke.primary) {
                    touchPoints.append(pixel)
                    centers.append(pixel)
                }
            }
        }
        
        linearInterpolation()
        
        centers.forEach { center in
            imageView.image = drawTip(x: center.x, y: center.y) ?? imageView.image
        }
        centers = [Pixel]()
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(movementEnabled || stroke.tool == .eyedropper) { return }
        if(stroke.tool == .replace) {
            context?.restoreGState()
        }
        
        touchPoints = [Pixel]()
        centers = [Pixel]()
        points = [Pixel]()
    }
    
    func createReplaceMask() {
        let image = imageView.image!
        guard let inputCGImage = image.cgImage else {
            return
        }
        
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let sec = stroke.secondary
        let secCG = CGColor.fromRGB(rgba: [CGFloat(sec.redComponent) / 255, CGFloat(sec.greenComponent) / 255, CGFloat(sec.blueComponent) / 255, CGFloat(sec.alphaComponent) / 255])
        
        context.setBlendMode(.difference)
        
        context.setFillColor(secCG)
        context.fill(CGRectMake(0, 0, CGFloat(width), CGFloat(height)))
        
        let intermediateCGImage = context.makeImage()!
        let intermediateImage = UIImage(cgImage: intermediateCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        replaceMask = intermediateImage.binarize().removeAlpha().convertToGrayScale()
    }
    
    func linearInterpolation() {
        for i in stride(from: 0, to: touchPoints.count - 1, by: 1) {
            let s = touchPoints[i]
            let c = touchPoints[i + 1]
            let line = plotLine(xS: s.x, yS: s.y, xC: c.x, yC: c.y)
            centers.insert(contentsOf: line, at: 0)
        }
        touchPoints = touchPoints.suffix(1)
    }
    
    func bezierInterpolation() {
        if touchPoints.count > 2 {
            for i in stride(from: 0, to: touchPoints.count - 2, by: 2) {
                let s = touchPoints[i]
                let c = touchPoints[i + 1]
                let e = touchPoints[i + 2]
                let curve = plotQuadBezier(x0: s.x, y0: s.y, x1: c.x, y1: c.y, x2: e.x, y2: e.y)
                centers.insert(contentsOf: curve, at: 0)
            }
            if touchPoints.count % 2 == 0 {
                touchPoints = touchPoints.suffix(2)
            }
            else {
                touchPoints = touchPoints.suffix(1)
            }
        }
    }
    
    func fillStrokeRegion() {
        if(stroke.tool == .brush || stroke.tool == .replace || stroke.tool == .fill) {
            guard let inputCGImage = imageView.image?.cgImage else {
                return
            }
            let colorSpace       = CGColorSpaceCreateDeviceRGB()
            let width            = inputCGImage.width
            let height           = inputCGImage.height
            let bytesPerPixel    = 4
            let bitsPerComponent = 8
            let bytesPerRow      = bytesPerPixel * width
            let bitmapInfo       = RGBA32.bitmapInfo
            
            guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                return
            }
            context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            guard let buffer = context.data else {
                return
            }
            
            let img = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
            
            centers.forEach { center in
                let area = stroke.tip.getTouchRegion(x: center.x, y: center.y).map( { Pixel(x: $0.0, y: $0.1, color: stroke.primary) } )
                
                for pixel in area {
                    if !(pixel.x >= 0 && pixel.y >= 0 && pixel.x < xBounds && pixel.y < yBounds) { continue }
                    let offset = pixel.y * xBounds + pixel.x
                    let currColor = img[offset]
                    if stroke.tool == .fill {
                        points.append(contentsOf: floodFill(img: img, px: Pixel(x: pixel.x, y: pixel.y, color: stroke.primary), color: currColor))
                    }
                }
            }
            
            imageView.image = changePixels(pixels: points)
            
            centers = [Pixel]()
            points = [Pixel]()
        }
    }
    
    func floodFill(img: UnsafeMutablePointer<RGBA32>, px: Pixel, color: RGBA32) -> [Pixel] {
        var pixels = [Pixel]()
        var visited = [[Bool]](
            repeating: [Bool](repeating: false, count: yBounds),
            count: xBounds
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
            if inside(x: x, y: y, color: color, img: img) && !visited[x][y] {
                while inside(x: x - 1, y: y, color: color, img: img) && !visited[x - 1][y] {
                    pixels.append(Pixel(x: x - 1, y: y, color: stroke.primary))
                    visited[x - 1][y] = true
                    x = x - 1
                }
                if x < x1 {
                    scanStack.push([x, x1 - 1, y - dy, -dy])
                }
            }
            while x1 <= x2 {
                while inside(x: x1, y: y, color: color, img: img) && !visited[x1][y] {
                    pixels.append(Pixel(x: x1, y: y, color: stroke.primary))
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
                while x1 < x2 && !(inside(x: x1, y: y, color: color, img: img) && !visited[x1][y]) {
                    x1 = x1 + 1
                }
                x = x1
            }
        }
        
        return pixels
    }
    
    func inside(x: Int, y: Int, color: RGBA32, img: UnsafeMutablePointer<RGBA32>) -> Bool {
        if !(x >= 0 && y >= 0 && x < xBounds && y < yBounds) { return false }
        let offset = y * xBounds + x
        let pxColor = img[offset]
        return x >= 0 && y >= 0 && x < xBounds && y < yBounds && color == pxColor
    }
    
    func generateContext() {
        guard let inputCGImage = imageView.image?.cgImage else {
            return
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        
        context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.interpolationQuality = .none
        context!.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    func refreshContext() {
        generateContext()
        if stroke.tool == .replace { createReplaceMask() }
    }
}

@available(iOS 13, *)
struct CanvasView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        CanvasView(frame: CGRect(x: 0, y: 0, width: 100, height: 200)).showPreview()
    }
}
