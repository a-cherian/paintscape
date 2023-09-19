//
//  CurveHelper.swift
//  Paintscape
//
//  Created by AC on 8/21/23.
//

import UIKit

func plotQuadBezier(x0: Int, y0: Int, x1: Int, y1: Int, x2: Int, y2: Int) -> [Pixel] {
    var xS = x0
    var yS = y0
    var xC = x1
    var yC = y1
    var xE = x2
    var yE = y2
    
    var pixels = [Pixel]()
    /* plot any quadratic Bezier curve */
    var deltaX = xS - xC,
    deltaY = yS - yC
    var t = Double(xS - 2 * xC + xE)
    var r = 0.0
    /* sign change in the x coordinates */
    if (deltaX * (xE - xC) > 0) {
        /* horizontal cut at P4? */
        if (deltaY * (yE - yC) > 0) {
            let a = Double(abs(yS - 2 * yC + yE * deltaX)) / t
            let b = Double(abs(deltaY))
            if (a > b) {
              /* vertical cut at P6 too? */
              /* which first? */
              xS = xE
              xE = deltaX + xC
              yS = yE
              yE = deltaY + yC /* swap points */
            } /* now horizontal cut at P4 comes first */
        }

        t = Double(xS - xC) / t
        r = (1.0 - t) * ((1.0 - t) * Double(yS) + 2.0 * t * Double(yC)) + t * t * Double(yE) /* By(t=P4) */
        t = (Double(xS * xE - xC * xC) * t) / Double(xS - xC) /* gradient dP4/dx=0 */
        deltaX = Int(floor(t + 0.5))
        deltaY = Int(floor(r + 0.5))
        r = (Double(yC - yS) * (t - Double(xS))) / Double(xC - xS) + Double(yS) /* intersect P3 | P0 P1 */
        pixels.append(contentsOf: plotQuadBezierSeg(x0: xS, y0: yS, x1: deltaX, y1: Int(floor(r + 0.5)), x2: deltaX, y2: deltaY))
        //plot control point for segment
        // plotPoints.push({
        //   x: deltaX,
        //   y: Math.floor(r + 0.5),
        //   color: `rgba(255,150,0,255)`,
        // })
        r = (Double(yC - yE) * (t - Double(xE))) / Double(xC - xE) + Double(yE) /* intersect P4 | P1 P2 */
        xC = deltaX
        xS = deltaX
        yS = deltaY
        yC = Int(floor(Double(r) + 0.5)) /* P0 = P4, P1 = P8 */
    }
    /* sign change in the y coordinates */
    if ((yS - yC) * (yE - yC) > 0) {
        /* vertical cut at P6? */
        t = Double(yS - 2 * yC + yE)
        t = Double(yS - yC) / t
        r = (1.0 - t) * ((1.0 - t) * Double(xS) + 2.0 * t * Double(xC)) + t * t * Double(xE) /* Bx(t=P6) */
        t = (Double(yS * yE - yC * yC) * t) / Double(yS - yC) /* gradient dP6/dy=0 */
        deltaX = Int(floor(r + 0.5))
        deltaY = Int(floor(t + 0.5))
//        r = ((xC - xS) * (t - yS)) / (yC - yS) + xS /* intersect P6 | P0 P1 */
        pixels.append(contentsOf: plotQuadBezierSeg(x0: xS, y0: yS, x1: Int(floor(r + 0.5)), y1: deltaY, x2: deltaX, y2: deltaY))
        //plot control point for segment
        // plotPoints.push({
        //   x: Math.floor(r + 0.5),
        //   y: deltaY,
        //   color: `rgba(0,255,150,255)`,
        // })
//        r = ((xC - xE) * (t - yE)) / (yC - yE) + xE /* intersect P7 | P1 P2 */
        xS = deltaX
        xC = Int(floor(r + 0.5))
        yC = deltaY
        yS = yC /* P0 = P6, P1 = P7 */
    }
    /* if no sign changes in x or y coordinates, only this segment will be generated */
    pixels.append(contentsOf: plotQuadBezierSeg(x0: xS, y0: yS, x1: xC, y1: yC, x2: xE, y2: yE))
    //plot control point for segment
    // plotPoints.push({
    //   x: xC,
    //   y: yC,
    //   color: `rgba(150,0,255,255)`,
    // })
    /* remaining part */
    return pixels
}

func plotQuadBezierSeg(x0: Int, y0: Int, x1: Int, y1: Int, x2: Int, y2: Int) -> [Pixel] {
    
    var pixels = [Pixel]()
    var xS = x0
    var yS = y0
    let xC = x1
    var yC = y1
    var xE = x2
    var yE = y2
    
    var sx = xE - xC
    var sy = yE - yC
    var xx = xS - xC
    var yy = yS - yC
    var xy = 0
    var cur = xx * sy - yy * sx
    var dx = Double(cur)
    var dy = dx
    var err = dx
    
    if xx * sx > 0 || yy * sy > 0 { return [] }

    if sx * sx + sy * sy > xx * xx + yy * yy { /* begin with longer part */
        xE = xS
        xS = Int(sx) + xC
        yE = yS
        yS = Int(sy) + yC
        cur = -cur
    }
    if (cur != 0) {                                    /* no straight line */
        xx += sx
        sx = xS < xE ? 1 : -1
        xx *= sx                                      /* x step direction */

        yy += sy
        sy = yS < yE ? 1 : -1
        yy *= sy                                       /* y step direction */
        
        xy = 2 * xx * yy
        xx *= xx
        yy *= yy                                      /* differences 2nd degree */
        if cur * sx * sy < 0 {                           /* negated curvature? */
            xx = -xx
            yy = -yy
            xy = -xy
            cur = -cur
        }
        
        dx = Double(4 * sy * cur * (xC - xS) + xx - xy)
                    /* differences 1st degree */
        dy = Double(4 * sx * cur * (yS - yC) + yy - xy)

        xx += xx
        yy += yy
        err = dx + dy + Double(xy)                /* error 1st step */
        repeat {
            pixels.append(Pixel(x: xS, y: yS, color: RGBA32()))
            if xS == xE && yS == yE { return pixels }  /* last pixel -> curve finished */
            yC = 2 * err < dx ? 1 : 0                  /* save value for test of y step */
            if 2 * err > dy {
                xS += sx
                
                dx -= Double(xy)
                dy += Double(yy)
                err += dy  /* x step */
            }
            if yC == 1 {
                yS += Int(sy)
              
                dy -= Double(xy)
                dx += Double(xx)
                err += dx
            } /* y step */
        } while dy < dx           /* gradient negates -> algorithm fails */
    }
    pixels.append(contentsOf: plotLine(xS: xS, yS: yS, xC: xE, yC: yE))                  /* plot remaining part to end */
    return pixels
}
    
func plotLine(xS: Int, yS: Int, xC: Int, yC: Int) -> [Pixel] {
    var xS = xS
    var yS = yS
    let xC = xC
    let yC = yC
    var pixels = [Pixel]()
    let dx =  abs(xC - xS)
    let sx = xS < xC ? 1 : -1
    let dy = -abs(yC - yS)
    let sy = yS < yC ? 1 : -1
    var err = dx + dy
    var e2 = 0; /* error value e_xy */

    while true {  /* loop */
        pixels.append(Pixel(x: xS, y: yS, color: RGBA32()))
        if xS == xC && yS == yC { return pixels }
        e2 = 2 * err
        if (e2 >= dy) {
            err += dy
            xS += sx
        }
        if (e2 <= dx) {
            err += dx
            yS += sy
        }
    }
}
