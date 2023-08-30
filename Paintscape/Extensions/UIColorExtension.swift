//
//  UIColorExtension.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

import UIKit

extension UIColor {
    typealias RGBA = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return getRed(&r, green: &g, blue: &b, alpha: &a) ? (round(r * 255), round(g * 255), round(b * 255), round(a * 255)) : nil
    }
}
