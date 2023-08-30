//
//  UIBezierPathExtension.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

import UIKit

// https://stackoverflow.com/questions/10477/equidistant-points-across-bezier-curves
extension UIBezierPath
{
    convenience init?(catmullRomPoints: [CGPoint], alpha: CGFloat) {
        self.init()
        
        if catmullRomPoints.count < 4 {
            return nil
        }
        
        let startIndex = 1
        let endIndex = catmullRomPoints.count - 2
        
        var i = startIndex
        while i < endIndex {
            let p0 = catmullRomPoints[i-1 < 0 ? catmullRomPoints.count - 1 : i - 1]
            let p1 = catmullRomPoints[i]
            let p2 = catmullRomPoints[(i+1)%catmullRomPoints.count]
            let p3 = catmullRomPoints[(i+1)%catmullRomPoints.count + 1]
            
            let d1 = p1.deltaTo(a: p0).length()
            let d2 = p2.deltaTo(a: p1).length()
            let d3 = p3.deltaTo(a: p2).length()
            
            var b1 = p2.multiplyBy(value: pow(d1, 2 * alpha))
            b1 = b1.deltaTo(a: p0.multiplyBy(value: pow(d2, 2 * alpha)))
            b1 = b1.addTo(a: p1.multiplyBy(value: 2 * pow(d1, 2 * alpha) + 3 * pow(d1, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b1 = b1.multiplyBy(value: 1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))
            
            var b2 = p1.multiplyBy(value: pow(d3, 2 * alpha))
            b2 = b2.deltaTo(a: p3.multiplyBy(value: pow(d2, 2 * alpha)))
            b2 = b2.addTo(a: p2.multiplyBy(value: 2 * pow(d3, 2 * alpha) + 3 * pow(d3, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b2 = b2.multiplyBy(value: 1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))
            
            if i == startIndex {
                move(to: p1)
            }
            
            addCurve(to: p2, controlPoint1: b1, controlPoint2: b2)
            i += 1
        }
    }
    
    func isInsideBorder(_ pos:CGPoint, toleranceWidth:CGFloat = 2.0)->Bool{
            let pathRef = cgPath.copy(strokingWithWidth: toleranceWidth, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.round, miterLimit: 0)
            let pathRefMutable = pathRef.mutableCopy()
            if let p = pathRefMutable {
                p.closeSubpath()
                return p.contains(pos)
            }
            return false
        }
    
    func getPoints() -> [CGPoint] {
        let pathBounds = bounds
        let minX = Int(pathBounds.minX)
        let maxX = Int(pathBounds.maxX)
        let minY = Int(pathBounds.minY)
        let maxY = Int(pathBounds.maxY)

        var pathPoints: [CGPoint] = []

        for x in minX...maxX {
            for y in minY...maxY {

                let point = CGPoint(x: CGFloat(x), y: CGFloat(y))

                if isInsideBorder(point, toleranceWidth: 0.5) {
                    pathPoints.append(point)
                }
            }
        }
        
        return pathPoints
    }
    
    func interpolatePointsWithHermite(interpolationPoints : [CGPoint], alpha : CGFloat = 1.0/3.0)
    {
        guard !interpolationPoints.isEmpty else { return }
        self.move(to: interpolationPoints[0])
        
        let n = interpolationPoints.count - 1
        
        for index in 0..<n
        {
            var currentPoint = interpolationPoints[index]
            var nextIndex = (index + 1) % interpolationPoints.count
            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
            var previousPoint = interpolationPoints[prevIndex]
            var nextPoint = interpolationPoints[nextIndex]
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if index > 0
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = interpolationPoints[nextIndex]
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex]
            nextPoint = interpolationPoints[nextIndex]
            
            if index < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
    
//    func solvePixelsAlongPath(start: Pixel, point1: Pixel, point2: Pixel, end: Pixel) -> [Pixel] {
//        let maxX = max(start.x, point1.x, point2.x, point2.x)
//        let maxY = max(start.y, point1.y, point2.y, end.y)
//        let startCG = CGPointMake(Int(start.x), Int(start.y))
//        let point1CG = CGPointMake(Int(point1.x), Int(point1.y))
//        let point2CG = CGPointMake(Int(point2.x), Int(point2.y))
//        let endCG = CGPointMake(Int(end.x), end.y)
//
//        var pixels = [Pixel]()
//        for i in minX...maxX {
//            let points = solveBezierAtX(startCG, point1CG, point2CG, endCG)
//            pixels.append(contentsOf: points.map { }(Pixel($0.x, $0.y, RGBA32())))
//        }
//
//        return pixels
//    }
    
//    func solveBezierAtY(start: CGPoint, point1: CGPoint, point2: CGPoint, end: CGPoint, y: CGFloat) -> [CGPoint] {
//
//        // bezier control points
//        let C0 = start.y - y
//        let C1 = point1.y - y
//        let C2 = point2.y - y
//        let C3 = end.y - y
//
//        // The cubic polynomial coefficients such that Bez(t) = A*t^3 + B*t^2 + C*t + D
//        let A = C3 - 3.0*C2 + 3.0*C1 - C0
//        let B = 3.0*C2 - 6.0*C1 + 3.0*C0
//        let C = 3.0*C1 - 3.0*C0
//        let D = C0
//
//        let roots = solveCubic(A, b: B, c: C, d: D)
//
//        var result = [CGPoint]()
//
//        for root in roots {
//            if (root >= 0 && root <= 1) {
//                result.append(bezierOutputAtT(start, point1: point1, point2: point2, end: end, t: root))
//            }
//        }
//
//        return result
//    }
//
//    func solveBezierAtX(start: CGPoint, point1: CGPoint, point2: CGPoint, end: CGPoint, x: CGFloat) -> [CGPoint] {
//
//        // bezier control points
//        let C0 = start.x - x
//        let C1 = point1.x - x
//        let C2 = point2.x - x
//        let C3 = end.x - x
//
//        // The cubic polynomial coefficients such that Bez(t) = A*t^3 + B*t^2 + C*t + D
//        let A = C3 - 3.0*C2 + 3.0*C1 - C0
//        let B = 3.0*C2 - 6.0*C1 + 3.0*C0
//        let C = 3.0*C1 - 3.0*C0
//        let D = C0
//
//        let roots = solveCubic(A, b: B, c: C, d: D)
//
//        var result = [CGPoint]()
//
//        for root in roots {
//            if (root >= 0 && root <= 1) {
//                result.append(bezierOutputAtT(start, point1: point1, point2: point2, end: end, t: root))
//            }
//        }
//
//        return result
//
//    }
//
//    func solveCubic(a: CGFloat?, var b: CGFloat, var c: CGFloat, var d: CGFloat) -> [CGFloat] {
//
//        if (a == nil) {
//            return solveQuadratic(b, b: c, c: d)
//        }
//
//        b /= a!
//        c /= a!
//        d /= a!
//
//        let p = (3 * c - b * b) / 3
//        let q = (2 * b * b * b - 9 * b * c + 27 * d) / 27
//
//        if (p == 0) {
//            return [pow(-q, 1 / 3)]
//
//        } else if (q == 0) {
//            return [sqrt(-p), -sqrt(-p)]
//
//        } else {
//
//            let discriminant = pow(q / 2, 2) + pow(p / 3, 3)
//
//            if (discriminant == 0) {
//                return [pow(q / 2, 1 / 3) - b / 3]
//
//            } else if (discriminant > 0) {
//                let x = crt(-(q / 2) + sqrt(discriminant))
//                let z = crt((q / 2) + sqrt(discriminant))
//                return [x - z - b / 3]
//            } else {
//
//                let r = sqrt(pow(-(p/3), 3))
//                let phi = acos(-(q / (2 * sqrt(pow(-(p / 3), 3)))))
//
//                let s = 2 * pow(r, 1/3)
//
//                return [
//                    s * cos(phi / 3) - b / 3,
//                    s * cos((phi + CGFloat(2) * CGFloat(M_PI)) / 3) - b / 3,
//                    s * cos((phi + CGFloat(4) * CGFloat(M_PI)) / 3) - b / 3
//                ]
//
//            }
//
//        }
//    }
//
//    func solveQuadratic(a: CGFloat, b: CGFloat, c: CGFloat) -> [CGFloat] {
//
//        let discriminant = b * b - 4 * a * c;
//
//        if (discriminant < 0) {
//            return []
//
//        } else {
//            return [
//                (-b + sqrt(discriminant)) / (2 * a),
//                (-b - sqrt(discriminant)) / (2 * a)
//            ]
//        }
//
//    }
//
//    private func crt(v: CGFloat) -> CGFloat {
//        if (v<0) {
//            return -pow(-v, 1/3)
//        }
//        return pow(v, 1/3)
//    }
//
//    private func bezierOutputAtT(start: CGPoint, point1: CGPoint, point2: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
//
//        // bezier control points
//        let C0 = start
//        let C1 = point1
//        let C2 = point2
//        let C3 = end
//
//        // The cubic polynomial coefficients such that Bez(t) = A*t^3 + B*t^2 + C*t + D
//        let A = CGPointMake(C3.x - 3.0*C2.x + 3.0*C1.x - C0.x, C3.y - 3.0*C2.y + 3.0*C1.y - C0.y)
//        let B = CGPointMake(3.0*C2.x - 6.0*C1.x + 3.0*C0.x, 3.0*C2.y - 6.0*C1.y + 3.0*C0.y)
//        let C = CGPointMake(3.0*C1.x - 3.0*C0.x, 3.0*C1.y - 3.0*C0.y)
//        let D = C0
//
//        return CGPointMake(((A.x*t+B.x)*t+C.x)*t+D.x, ((A.y*t+B.y)*t+C.y)*t+D.y)
//    }
}
