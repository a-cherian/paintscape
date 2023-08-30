//
//  DrawViewOld.swift
//  Paintscape
//
//  Created by AC on 8/16/23.
//

import UIKit
import SwiftUI

enum Tool {
    case brush
    case eraser
    case eyedropper
}

class DrawViewOld: UIView {

    var currentTool: Tool?
    var points = [CGPoint]()
    let backgroundLayer = CAShapeLayer()
    let drawingLayer = CAShapeLayer()
    let path = UIBezierPath()
    var interpolationPoints = [CGPoint]()
    
    required init(frameWidth: CGFloat, frameHeight: CGFloat)
    {
        super.init(frame: CGRect(x:0, y: 0, width: frameWidth, height: frameHeight))
        
        backgroundLayer.strokeColor = UIColor.darkGray.cgColor
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = 1
        
        drawingLayer.strokeColor = UIColor.black.cgColor
        drawingLayer.fillColor = nil
        drawingLayer.lineWidth = 1
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(drawingLayer)
        
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 1
        layer.magnificationFilter = .nearest
        layer.minificationFilter = .nearest
        layer.masksToBounds = true
        
        frame.size.height = frameHeight
        frame.size.width = frameWidth
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false);
        context?.setAllowsAntialiasing(false)
        print(frame.height)
        print(frame.width)
        super.draw(rect)
    }
    
//     Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        print("draw method called")
//
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        points.forEach { point in
//            context.setFillColor(UIColor.purple.cgColor)
//            context.fill(CGRect(x: point.x, y: point.y, width: 1, height: 1))
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
//        points.append(touch.location(in: self))
        
        beginScribble(point: touch.location(in: self))
        
        drawTool(selectedTool: .brush)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touches.forEach { touch in
//            let tapPoint = touch.location(in: self)
//            points.append(tapPoint)
//
//            if let coalescedTouches = event?.coalescedTouches(for: touch) {
//                points += coalescedTouches.map { $0.location(in: self) }
//            } else {
//                points.append(touch.location(in: self))
//            }
//
//            print(points)
//        }
        
//        if let coalescedTouches = event?.coalescedTouches(for: touch) {
//            coalescedTouches.forEach
//            {
//                appendScribble($0.location(in: self))
//            }
//        }
        
        touches.forEach {
            appendScribble(point: $0.location(in: self))
        }
        
        drawTool(selectedTool: .brush)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endScribble()
        drawTool(selectedTool: .brush)
    }
    
    private func drawTip(user context: CGContext) {
//        context.fill(CGRect(x: xValue, y: yValue, width: 1, height: 1))
    }
    
    func drawTool(selectedTool: Tool) {
        currentTool = selectedTool
        setNeedsDisplay()
    }
    
    func beginScribble(point: CGPoint)
    {
        interpolationPoints = [point]
    }

    func appendScribble(point: CGPoint)
    {
        interpolationPoints.append(point)
        
        path.removeAllPoints()
//        path.interpolatePointsWithHermite(interpolationPoints: interpolationPoints)
        
        drawingLayer.path = path.cgPath
    }
    
    func endScribble()
    {
        if let backgroundPath = backgroundLayer.path
        {
            path.append(UIBezierPath(cgPath: backgroundPath))
        }
        
        backgroundLayer.path = path.cgPath
        
        path.removeAllPoints()
        
        drawingLayer.path = path.cgPath
    }
    
    func clearScribble()
    {
        backgroundLayer.path = nil
    }
}

@available(iOS 13, *)
struct DrawViewOld_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        DrawViewOld(frameWidth: 500, frameHeight: 500).showPreview()
    }
}
