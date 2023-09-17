//
//  CGColorExtension.swift
//  Paintscape
//
//  Created by AC on 9/16/23.
//

import UIKit

extension CGColor
{
  static func fromRGB(rgba array:[CGFloat]) -> CGColor {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    return array.withUnsafeBufferPointer({ (ptr) -> CGColor in
      let baseAddress = ptr.baseAddress!
      let color = CGColor(colorSpace: colorSpace, components: baseAddress)!
      return color
    })
  }

  static func fromDevice(graya array:[CGFloat]) -> CGColor {
    let colorSpace = CGColorSpaceCreateDeviceGray()
    return array.withUnsafeBufferPointer({ (ptr) -> CGColor in
      let baseAddress = ptr.baseAddress!
      let color = CGColor(colorSpace: colorSpace, components: baseAddress)!
      return color
    })
  }
}
