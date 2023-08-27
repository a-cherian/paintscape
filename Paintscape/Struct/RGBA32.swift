//
//  RGBA32.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

import UIKit

struct RGBA32: Equatable {
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init() {
        let red   = UInt32(0)
        let green = UInt32(0)
        let blue  = UInt32(0)
        let alpha = UInt32(255)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }

    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        let red   = UInt32(r)
        let green = UInt32(g)
        let blue  = UInt32(b)
        let alpha = UInt32(a)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
    
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat, nType: CGFloat.Type) {
        let red   = UInt32(Int(r))
        let green = UInt32(Int(g))
        let blue  = UInt32(Int(b))
        let alpha = UInt32(Int(a))
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }

    static let red     = RGBA32(r: 255, g: 0,   b: 0,   a: 255)
    static let green   = RGBA32(r: 0,   g: 255, b: 0,   a: 255)
    static let blue    = RGBA32(r: 0,   g: 0,   b: 255, a: 255)
    static let white   = RGBA32(r: 255, g: 255, b: 255, a: 255)
    static let black   = RGBA32(r: 0,   g: 0,   b: 0,   a: 255)
    static let magenta = RGBA32(r: 255, g: 0,   b: 255, a: 255)
    static let yellow  = RGBA32(r: 255, g: 255, b: 0,   a: 255)
    static let cyan    = RGBA32(r: 0,   g: 255, b: 255, a: 255)

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}
