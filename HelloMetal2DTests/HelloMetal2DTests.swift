//
//  HelloMetal2DTests.swift
//  HelloMetal2DTests
//
//  Created by Denis Dobynda on 22.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import XCTest

class HelloMetal2DTests: XCTestCase {

    var generator: LTreeGenerator?
//    var parser: TurtleParser?
    
    let opt = [
        "F" : 1,
        "P" : 1,
        //            "+" : 2,
        //            "-" : 3,
        "[" : 0,
        "]" : -1,
        "Z" : 2,
        "z" : 3,
        "Y" : 4,
        "y" : 5,
        "X" : 6,
        "x" : 7,
        "+" : 1,
        ]
    
    
    override func setUp() {
        generator = LTreeGenerator(with: [("F", "F[Fz[zFZXFZYF]Z[ZFxzFyzF]F]")])
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
    
//    func testGenerator() {
//        guard let generator = generator else {return}
//        let s1 = generator.getLine(after: 1) == "FF+[+F-F-F]-[-F+F+F]"
//        let s2 = generator.getLine(after: 2) == "FF+[+F-F-F]-[-F+F+F]FF+[+F-F-F]-[-F+F+F]+[+FF+[+F-F-F]-[-F+F+F]-FF+[+F-F-F]-[-F+F+F]-FF+[+F-F-F]-[-F+F+F]]-[-FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]]"
//        print("1 \(s1)")
//        print("2 \(s2)")
//    }
    
    func testParser() {
        guard let generator = generator else {return}
        let parser = TurtleParser(generator.getLine(after: 2), options: opt)
        let points = parser.parse(starting: [0.0,0.0,0.0], direction: Vector3(0.0, 1.0, 0.0))
        print(points!)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
