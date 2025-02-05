//
//  UIImageExtension.swift
//  Paintscape
//
//  Created by AC on 9/13/23.
//

import UIKit

extension UIImage
{
    // https://stackoverflow.com/questions/31661023/change-color-of-certain-pixels-in-a-uiimage
    func getPixel(pixel: Pixel) -> RGBA32 {
        guard let inputCGImage = self.cgImage else {
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
        
        if pixel.x > 0 && pixel.y > 0 && pixel.x < width && pixel.y < height {
            let offset = pixel.y * width + pixel.x
            let currColor = pixelBuffer[offset]
            return currColor
        }
        
        return RGBA32()
    }
    
    func cropImage(toRect cropRect: CGRect, view: UIImageView, mask: CGImage? = nil) -> UIImage?
    {
        let viewWidth = view.frame.size.width
        let viewHeight = view.frame.size.height
        let imageViewScale = max(self.size.width / viewWidth,
                                 self.size.height / viewHeight)


        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)


        // Perform cropping in Core Graphics
        var cutImageRef = self.cgImage?.cropping(to:cropZone)
        
        if mask != nil, let mask = UIImage(cgImage: mask!).cropImage(toRect: cropRect, view: view)?.removeAlpha().convertToGrayScale().cgImage {
            guard let croppedCGImage = cutImageRef else { return nil }
            
            let colorSpace       = CGColorSpaceCreateDeviceRGB()
            let width            = croppedCGImage.width
            let height           = croppedCGImage.height
            let bytesPerPixel    = 4
            let bitsPerComponent = 8
            let bytesPerRow      = bytesPerPixel * width
            let bitmapInfo       = RGBA32.bitmapInfo
            
            
            let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            context?.interpolationQuality = .none
            context?.clip(to: CGRect(x: 0, y: 0, width: width, height: height), mask: mask)
            context?.draw(croppedCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            cutImageRef = context?.makeImage()
        }
        
        guard let croppedCGImage = cutImageRef else { return nil }
        let croppedImage: UIImage = UIImage(cgImage: croppedCGImage)
        return croppedImage
    }

    
    func scaleProportional(width: CGFloat) -> UIImage {
        guard self.size.width != width else { return self }
        
        let scaleFactor = width / self.size.width
        
        let height = self.size.height * scaleFactor
        let newSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.interpolationQuality = .none
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    func scale(width: CGFloat, height: CGFloat) -> UIImage {
        guard self.size.width != width else { return self }
        
        let newSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.interpolationQuality = .none
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    func removeAlpha() -> UIImage {
        let format = UIGraphicsImageRendererFormat.init()
        format.opaque = true //Removes Alpha Channel
        format.scale = self.scale //Keeps original image scale.
        let size = self.size
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func convertToGrayScale() -> UIImage {
        let imageRect:CGRect = CGRect(x:0, y:0, width:self.size.width, height: self.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = self.size.width
        let height = self.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        //have to draw before create image
        
        context?.draw(self.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    func binarize(invert: Bool = true) -> UIImage {
        guard let cgImage = self.cgImage else { return UIImage() }
        guard let cPolyFilter = CIFilter(name: "CIColorCrossPolynomial") else { return UIImage() }
        cPolyFilter.setDefaults()
        cPolyFilter.setValue(CIImage(cgImage: cgImage/*, options: [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB()]*/), forKey: kCIInputImageKey)
        let rgbVector = CIVector(values: [255, 255, 255, 255, 255, 255, 255, 255, 255, 0], count: 10)
        
        cPolyFilter.setValue(rgbVector, forKey: "inputRedCoefficients")
        cPolyFilter.setValue(rgbVector, forKey: "inputGreenCoefficients")
        cPolyFilter.setValue(rgbVector, forKey: "inputBlueCoefficients")
        
        
        guard let cPolyOutput = cPolyFilter.outputImage else { return UIImage() }
        cPolyFilter.setValue(cPolyOutput, forKey: kCIInputImageKey)
        guard let cPolyOutput2 = cPolyFilter.outputImage else { return UIImage() }
            
        if invert {
            guard let invertFilter = CIFilter(name: "CIColorInvert") else { return UIImage() }
            invertFilter.setDefaults()
            invertFilter.setValue(cPolyOutput2, forKey: kCIInputImageKey)
            guard let invertOutput = invertFilter.outputImage, let cgImage = CIContext().createCGImage(invertOutput, from: invertOutput.extent) else { return UIImage() }
            return UIImage(cgImage: cgImage)
        }
        else {
            guard let cgImage = CIContext().createCGImage(cPolyOutput2, from: cPolyOutput2.extent) else { return UIImage() }
            return UIImage(cgImage: cgImage)
        }
    }
}
