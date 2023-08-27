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
    
    func testQuadBezierSeg() {
        let start = Pixel(x: 9, y: 8, color: RGBA32())
        let control = Pixel(x: 11, y: 9, color: RGBA32())
        let end = Pixel(x: 9, y: 9, color: RGBA32())
        let pixels = plotQuadBezierSeg(s: start, c1: control, e: end)
        print(pixels)
    }
    
    func testQuadBezierSeg2() {
        let start = Pixel(x: 11 + 300, y: 8 + 300, color: RGBA32())
        let control = Pixel(x: 9 + 300, y: 9 + 300, color: RGBA32())
        let end = Pixel(x: 11 + 300, y: 9 + 300, color: RGBA32())
        let pixels = plotQuadBezierSeg(s: start, c1: control, e: end)
        print(pixels)
    }
    
    func testQuadBezierSeg3() {
        let start = Pixel(x: 10, y: 8, color: RGBA32())
        let control = Pixel(x: 9, y: 7, color: RGBA32())
        let end = Pixel(x: 10, y: 7, color: RGBA32())
        let pixels = plotQuadBezierSeg(s: start, c1: control, e: end)
        print(pixels)
    }
}
