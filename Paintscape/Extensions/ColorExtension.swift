//
//  ColorExtension.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

import SwiftUI

extension Color {
    var uiColor: UIColor { .init(self) }
    typealias RGBA = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (round(r * 255), round(g * 255), round(b * 255), round(a * 255)) : nil
    }
    
    var hexaRGB: String? {
        guard let (red, green, blue, _) = rgba else { return nil }
        return String(format: "#%02x%02x%02x",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255))
    }
    
    var hexaRGBA: String? {
        guard let (red, green, blue, alpha) = rgba else { return nil }
        return String(format: "#%02x%02x%02x%02x",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255),
            Int(alpha * 255))
    }
}
