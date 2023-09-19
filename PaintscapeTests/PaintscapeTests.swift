//
//  PaintscapeTests.swift
//  PaintscapeTests
//
//  Created by AC on 8/15/23.
//

import XCTest

final class PaintscapeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTipGetRegion() {
        measure {
            let tip = Tip(type: .square, r: 5)
            let output = tip.getTouchRegion(x: 0, y: 0)
            print(output)
        }
//        XCTAssertEqual(input.uppercasedFirst(), expectedOutput, "The String is not correctly capitalized.")
    }
    
    func testTipCutCorners() {
        measure {
            let tip = Tip(type: .circle, r: 5)
            let output = tip.getTouchRegion(x: 0, y : 0)
            print(output)
        }
//        XCTAssertEqual(input.uppercasedFirst(), expectedOutput, "The String is not correctly capitalized.")
    }
    
    func testTipCutCorners2() {
        measure {
            let tip = Tip(type: .circle, r: 6)
            let output = tip.getTouchRegion(x: 0, y : 0)
            print(output)
        }
//        XCTAssertEqual(input.uppercasedFirst(), expectedOutput, "The String is not correctly capitalized.")
    }
    
    func testTipCutCorners3() {
        measure {
            let tip = Tip(type: .circle, r: 2)
            let output = tip.getTouchRegion(x: 0, y : 0)
            print(output)
        }
//        XCTAssertEqual(input.uppercasedFirst(), expectedOutput, "The String is not correctly capitalized.")
    }
    
    func testHistoryAdd() {
        let pixel = Pixel(x: 1, y: 2, color: RGBA32(r: 5, g: 5, b: 5, a: 5))
        var hist = History(maxItems: 3)
        hist.add(action: [pixel])
        
        let expectedHistory = [[pixel]]
        XCTAssertEqual(hist.history, expectedHistory)
        XCTAssertEqual(hist.current, 0)
    }
    
    func testHistoryAddMax() {
        let pixel = Pixel(x: 1, y: 2, color: RGBA32(r: 5, g: 5, b: 5, a: 5))
        var hist = History(maxItems: 3)
        hist.add(action: [pixel])
        hist.add(action: [pixel, pixel])
        hist.add(action: [pixel, pixel, pixel])
        hist.add(action: [pixel, pixel, pixel, pixel])
        
        let expectedHistory = [[pixel, pixel], [pixel, pixel, pixel], [pixel, pixel, pixel, pixel]]
        XCTAssertEqual(hist.history, expectedHistory)
        XCTAssertEqual(hist.current, 2)
    }
    
    func testBigStrokeSpeed() {
        measure {
            let stroke = Stroke(tool: .brush, tip: Tip(type: .square, r: 30), primary: RGBA32(), secondary: RGBA32())
            for _ in 1...1000 {
                let area = stroke.tip.getTouchRegion(x: 100, y: 100)
            }
        }
    }
    
    func testCreateMaskSpeed() {
        measure {
            let canvas = CanvasView(frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
            canvas.createReplaceMask()
        }
    }
    
    func testCreateNoiseMasksSpeed() {
        measure {
            let canvas = CanvasView(frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
//            var noiseMasks = [[UIImage]]()
//            let sprayNozzleSizes = [3, 9, 15, 21]
//            sprayNozzleSizes.forEach { i in
//                var noiseMaskGroup = [UIImage]()
//                for _ in 0...10 {
//                    noiseMaskGroup.append(canvas.createNoiseMask(bwRatio: i))
//                }
//                noiseMasks.append(noiseMaskGroup)
//            }
        }
    }
}
