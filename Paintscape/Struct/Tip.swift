//
//  Tip.swift
//  Paintscape
//
//  Created by AC on 8/18/23.
//

enum TipType {
    case circle
    case square
}

struct Tip {
    var type: TipType
    var radius: Int
    var region: [(x: Int, y: Int)]
    var width: Int
    
    init(type: TipType, r: Int) {
        self.type = type
        self.radius = r
        self.width = r
        if type == .circle {
            if(r == 1) {
                self.region = [(x: 0, y: 0)]
                self.width = 1
            }
            else if(r == 2) {
                self.region = [(x: 0, y: 0), (x: 0, y: -1), (x: 1, y: 0), (x: 1, y: -1)]
                self.width = 2
            }
            else {
                self.region = Tip.cutCorners(square: Tip.getSquareRegion(radius: r + 2), r: r + 2)
                self.width = r + 2
            }
        }
        else {
            self.region = Tip.getSquareRegion(radius: r)
        }
    }
    
    static func getSquareRegion(radius: Int) -> [(Int, Int)] {
        if radius == 1 {
            return [(0, 0)]
        }
        
        var p: [(x: Int, y: Int)] = getSquareRegion(radius: radius - 1)
        let upperRight = p.last!
        
        if radius % 2 == 0 {
            for xCoord in (upperRight.x - (radius - 2))...upperRight.x {
                p.append((x: xCoord, y: upperRight.y - 1))
            }
            
            for yCoord in upperRight.y...(upperRight.y + (radius - 2)) {
                p.append((x: upperRight.x + 1, y: yCoord))
            }
            
            p.append((x: upperRight.x + 1, y: upperRight.y - 1))
            
            return p
        }
        else {
            let lowerLeft = (x: upperRight.x - (radius - 2), y: upperRight.y + (radius - 2))
            
            for xCoord in lowerLeft.x...(lowerLeft.x + (radius - 2)) {
                p.append((x: xCoord, y: lowerLeft.y + 1))
            }
            
            for yCoord in (lowerLeft.y - (radius - 2)...lowerLeft.y) {
                p.append((x: lowerLeft.x - 1, y: yCoord))
            }
            
            p.append((x: lowerLeft.x - 1, y: lowerLeft.y + 1))
            p.append((x: upperRight.x, y: upperRight.y))
            
            return p
        }
    }
    
    static func cutCorners(square: [(x: Int, y: Int)], r: Int) -> [(Int, Int)] {
        let lB: Int = (r / 2 - (r % 2 == 0 ? 1 : 0)) * -1
        let tB: Int = (r / 2) * -1
        let rB: Int = r + lB
        let bB: Int = r + tB
        let cSize: Int = (r - (r / 3) - (r % 2 == 1 ? 1 : 0)) / 2
        
        var circle = square
        
        for i in 0...(cSize - 1) {
            for j in 0...(cSize - i - 1) {
                circle = circle.filter { !($0 == (x: lB + i, y: tB + j) || $0 == (x: rB - 1 - i, y: tB + j) ||  $0 == (x: lB + i, y: bB - 1 - j) || $0 == (x: rB - 1 - i, y: bB - 1 - j))}
            }
        }
        
        return circle
    }
    
    func getTouchRegion(x: Int, y: Int) -> [(Int, Int)] {
        region.map { (x: $0.x + x, y: $0.y + y) }
    }
    
    func getTipRegion() -> [(x: Int, y: Int)] {
        let w = width
        return region.map { (x: $0.x + w / 2 - (w % 2 == 1 ? 0 : 1), y: $0.y + w / 2) }
    }
}
