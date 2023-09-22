//
//  CGPointExtension.swift
//  Paintscape
//
//  Created by AC on 9/20/23.
//

import UIKit

extension CGPoint {
    func pixelAlign(view: UIImageView) -> CGPoint {
        let pixel = Pixel(point: self, view: view)
        let xBounds = view.image!.scale * view.image!.size.width
        let yBounds = view.image!.scale * view.image!.size.height
        let xRatio = xBounds / view.frame.size.width
        let yRatio = yBounds / view.frame.size.height
        
        return CGPoint(x: CGFloat(pixel.x) / xRatio, y: CGFloat(pixel.y) / yRatio)
    }
}
