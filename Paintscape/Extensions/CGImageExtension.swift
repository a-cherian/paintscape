//
//  CGImageExtension.swift
//  Paintscape
//
//  Created by AC on 9/18/23.
//

import UIKit

extension CGImage
{
    func tileImage(context: CGContext, height: Int, width: Int) -> CGImage {
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
        context.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height), byTiling: true)
        return context.makeImage()!
    }
}
