//
//  Pixel.swift
//  Paintscape
//
//  Created by AC on 8/20/23.
//

import UIKit

struct Pixel: Equatable, Hashable {
    var x: Int
    var y: Int
    var color: RGBA32

    init(x: Int, y: Int, color: RGBA32) {
        self.x = x
        self.y = y
        self.color = color
    }
    
    init(point: CGPoint, view: UIImageView, color: RGBA32) {
        let xRatio = view.image!.scale * (view.image!.size.width / view.frame.size.width)
        let yRatio = view.image!.scale * (view.image!.size.height / view.frame.size.height)
        self.x = Int(round(xRatio * point.x)) - 1
        self.y = Int(round(yRatio * point.y)) - 1
        self.color = color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
