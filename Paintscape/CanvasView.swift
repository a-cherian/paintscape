//
//  CanvasView.swift
//  Paintscape
//
//  Created by AC on 8/16/23.
//

import UIKit
import SwiftUI
import MagnifyingGlass

protocol CanvasViewDelegate: AnyObject {
    func didColorChange(_ color: RGBA32)
}

// https://stackoverflow.com/a/41009006/4488252
class CanvasView: UIView {
    weak var delegate: CanvasViewDelegate?
    var movementEnabled = false
    var eyedropper = false
    var stroke = Stroke()
    let imageView = UIImageView()
    private lazy var path = UIBezierPath()
    private lazy var previousTouchPoint = CGPoint.zero
    var touchPoints = [Pixel]()
    var centers = [Pixel]()
    var action = [Pixel: Pixel]()
    var history = History(maxItems: 50)
    var magnifyingGlass = MagnifyingGlassView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), true, 0);
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.white.cgColor)
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        let img = UIGraphicsGetImageFromCurrentImageContext() ??  UIImage();
        UIGraphicsEndImageContext();
        
        imageView.image = img
        imageView.setNeedsDisplay()
        
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
        let width = Int(imageView.image!.size.width * imageView.image!.scale)
        let height = Int(imageView.image!.size.height * imageView.image!.scale)
        let pixels = history.undo(image: imageView.image!, width: width, height: height)
        imageView.image = changePixels(in: imageView.image!, pixels: pixels, stroke: Stroke(tool: "history"))
        setNeedsDisplay()
    }
    
    func redo() {
        let width = Int(imageView.image!.size.width * imageView.image!.scale)
        let height = Int(imageView.image!.size.height * imageView.image!.scale)
        let pixels = history.redo(image: imageView.image!, width: width, height: height)
        imageView.image = changePixels(in: imageView.image!, pixels: pixels, stroke: Stroke(tool: "history"))
        setNeedsDisplay()
    }
    
    func eyedropper(location: CGPoint) {
        delegate?.didColorChange(getPixel(in: imageView.image!, pixel: Pixel(point: location, view: imageView, color: RGBA32())))
    }
    
    // https://stackoverflow.com/questions/31661023/change-color-of-certain-pixels-in-a-uiimage
    func changePixels(in image: UIImage, pixels: [Pixel], stroke: Stroke) -> UIImage? {
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
        
        let xBounds = Int(imageView.image!.size.width * imageView.image!.scale)
        let yBounds = Int(imageView.image!.size.height * imageView.image!.scale)
        
        pixels.forEach { center in
            var area = stroke.calculatePixels(img: pixelBuffer, px: center, xBounds: xBounds, yBounds: yBounds)
            
            area = area.filter({ action[$0] == nil })
            area.forEach { pixel in
                let offset = pixel.y * xBounds + pixel.x
                if stroke.tool != "history" {
                    action[pixel] = action[pixel] ?? Pixel(x: pixel.x, y: pixel.y, color: pixelBuffer[offset])
                }
                pixelBuffer[offset] = pixel.color
            }
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
//        ii
        centers = [Pixel]()
        
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
        
        let xBounds = Int(imageView.image!.size.width * imageView.image!.scale)
        let yBounds = Int(imageView.image!.size.height * imageView.image!.scale)
        
        if pixel.x > 0 && pixel.y > 0 && pixel.x < xBounds && pixel.y < yBounds {
            let offset = pixel.y * xBounds + pixel.x
            let currColor = pixelBuffer[offset]
            return currColor
        }
    
       return RGBA32()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(movementEnabled || eyedropper) { return }
        
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        touchPoints.append(Pixel(point: point, view: imageView, color: stroke.primary))
        imageView.image = changePixels(in: imageView.image!, pixels: touchPoints, stroke: stroke)
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(movementEnabled || eyedropper) { return }
        
        super.touchesMoved(touches, with: event)
        touches.forEach { touch in
            touchPoints.append(Pixel(point: touch.location(in: self), view: imageView, color: stroke.primary))

            if let coalescedTouches = event?.coalescedTouches(for: touch) {
                touchPoints += coalescedTouches.map { Pixel(point: $0.location(in: self), view: imageView, color: stroke.primary) }
            } else {
                touchPoints.append(Pixel(point: touch.location(in: self), view: imageView, color: stroke.primary))
            }
        }
        
        if touchPoints.count > 2 {
            for i in stride(from: 0, to: touchPoints.count - 3, by: 1) {
                let s = touchPoints[i]
                let c = touchPoints[i + 1]
                let e = touchPoints[i + 2]
                let curve = plotQuadBezierSeg(x0: s.x, y0: s.y, x1: c.x, y1: c.y, x2: e.x, y2: e.y)
                centers.insert(contentsOf: curve, at: 0)
            }
            touchPoints = touchPoints.suffix(3)
            let s = touchPoints[0]
            let c = touchPoints[1]
            let e = touchPoints[2]
            let curve = plotQuadBezierSeg(x0: s.x, y0: s.y, x1: c.x, y1: c.y, x2: e.x, y2: e.y)
            centers.insert(contentsOf: curve, at: 0)
        }
        
        imageView.image = changePixels(in: imageView.image!, pixels: centers, stroke: stroke)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(movementEnabled || eyedropper) { return }
        
        history.add(action: Array(action.values))
        action = [Pixel: Pixel]()
        
        touchPoints = [Pixel]()
        centers = [Pixel]()
    }
}

@available(iOS 13, *)
struct CanvasView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        CanvasView(frame: CGRect(x: 0, y: 0, width: 100, height: 200)).showPreview()
    }
}
