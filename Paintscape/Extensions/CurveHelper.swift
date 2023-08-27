//
//  CurveHelper.swift
//  Paintscape
//
//  Created by AC on 8/21/23.
//

import UIKit

// TO DO: convert to swift
//func plotQuadBezier(x0: Int, y0: Int, x1: Int, y1: Int, x2: Int, y2: Int) -> [Pixel]() {
//  var pixels = [Pixel]()
//var xS = x0
//var yS = y0
//let xC = x1
//var yC = y1
//var xE = x2
//var yE = y2
//
//  /* plot any quadratic Bezier curve */
//  let deltaX = xS - xC,
//    deltaY = yS - yC
//  let t = xS - 2 * xC + xE,
//    r
//  /* sign change in the x coordinates */
//  if (deltaX * (xE - xC) > 0) {
//    /* horizontal cut at P4? */
//    if (deltaY * (yE - yC) > 0)
//      if (Math.abs(((yS - 2 * yC + yE) * deltaX) / t) > Math.abs(deltaY)) {
//        /* vertical cut at P6 too? */
//        /* which first? */
//        xS = xE
//        xE = deltaX + xC
//        yS = yE
//        yE = deltaY + yC /* swap points */
//      } /* now horizontal cut at P4 comes first */
//    t = (xS - xC) / t
//    r = (1 - t) * ((1 - t) * yS + 2.0 * t * yC) + t * t * yE /* By(t=P4) */
//    t = ((xS * xE - xC * xC) * t) / (xS - xC) /* gradient dP4/dx=0 */
//    deltaX = Math.floor(t + 0.5)
//    deltaY = Math.floor(r + 0.5)
//    r = ((yC - yS) * (t - xS)) / (xC - xS) + yS /* intersect P3 | P0 P1 */
//    plotQuadBezierSeg(
//      xS,
//      yS,
//      deltaX,
//      Math.floor(r + 0.5),
//      deltaX,
//      deltaY,
//      `rgba(255,0,0,255)`
//    )
//    //plot control point for segment
//    // plotPoints.push({
//    //   x: deltaX,
//    //   y: Math.floor(r + 0.5),
//    //   color: `rgba(255,150,0,255)`,
//    // })
//    r = ((yC - yE) * (t - xE)) / (xC - xE) + yE /* intersect P4 | P1 P2 */
//    xS = xC = deltaX
//    yS = deltaY
//    yC = Math.floor(r + 0.5) /* P0 = P4, P1 = P8 */
//  }
//  /* sign change in the y coordinates */
//  if ((yS - yC) * (yE - yC) > 0) {
//    /* vertical cut at P6? */
//    t = yS - 2 * yC + yE
//    t = (yS - yC) / t
//    r = (1 - t) * ((1 - t) * xS + 2.0 * t * xC) + t * t * xE /* Bx(t=P6) */
//    t = ((yS * yE - yC * yC) * t) / (yS - yC) /* gradient dP6/dy=0 */
//    deltaX = Math.floor(r + 0.5)
//    deltaY = Math.floor(t + 0.5)
//    r = ((xC - xS) * (t - yS)) / (yC - yS) + xS /* intersect P6 | P0 P1 */
//    plotQuadBezierSeg(
//      xS,
//      yS,
//      Math.floor(r + 0.5),
//      deltaY,
//      deltaX,
//      deltaY,
//      `rgba(0,255,0,255)`
//    )
//    //plot control point for segment
//    pixels.append(Pixel(x: Math.floor(r + 0.5), y: deltaY, color: RGBA32()))
//    r = ((xC - xE) * (t - yE)) / (yC - yE) + xE /* intersect P7 | P1 P2 */
//    xS = deltaX
//    xC = Math.floor(r + 0.5)
//    yS = yC = deltaY /* P0 = P6, P1 = P7 */
//  }
//  /* if no sign changes in x or y coordinates, only this segment will be generated */
//  plotQuadBezierSeg(x0: xS, y0: yS, x1: xC, y1: yC, x2: xE, y2: yE)
  //plot control point for segment
  // pixels.append(Pixel(x: xC, y: yC, color: RGBA32()))
  /* remaining part */
//  return pixels
//}

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
