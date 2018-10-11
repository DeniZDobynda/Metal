//
//  TurtleParser.swift
//  HelloMetal2D
//
//  Created by Denis Dobynda on 16.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import UIKit

class TurtleParser: NSObject {
    
    var line: String?
    var options: [String:Int]?
    
    override init() {
        super.init()
        line = ""
        options = Dictionary<String, Int>()
    }
    init(_ lineToParse: String) {
        super.init()
        line = lineToParse
        options = Dictionary<String, Int>()
    }
    init(_ lineToParse: String, options: [String:Int]) {
        super.init()
        line = lineToParse
        self.options = options
    }
    
    func parse(starting from: [Float], direction: Vector3, angle: Float = 30.0) -> [[Float]]? {
        guard  let line = line, let _ = options, from.count == 3 else { return nil }
//        var vertexes = [[Float]]()
//        var currentDirection = direction
//        var currentPosition = from
//        var index = line.startIndex
//
//        var currentVertexIndex = 0
//        vertexes.append([Float]())
//        vertexes[0].append(contentsOf: currentPosition)
//        while index != line.endIndex {
//            let ch = line[index]
//            if let opt = options[String(ch)] {
//                switch opt {
//                case 1:
//                    // move Forward
//                    currentPosition = [
//                        currentPosition[0] + currentDirection.x,
//                        currentPosition[1] + currentDirection.y,
//                        currentPosition[2] + currentDirection.z
//                    ]
//                    vertexes[currentVertexIndex].append(contentsOf: currentPosition)
//                case 2:
//                    // rotate positive
//                    print(currentDirection.x, currentDirection.y)
//                    currentDirection.xy = currentDirection.xy.rotated(by: -1.0 * angle * .radiansPerDegree)
//                    print(currentDirection.x, currentDirection.y)
//                case 3:
//                    // rotate positive
//                    currentDirection.xy = currentDirection.xy.rotated(by: angle * .radiansPerDegree)
//                case 0:
//                    let savedPosition = currentPosition
//                    let savedDirection = currentDirection
//                    if vertexes[currentVertexIndex].count > 3 {
//                        currentVertexIndex += 1
//                        vertexes.append([Float]())
//                        vertexes[currentVertexIndex].append(contentsOf: currentPosition)
//                    }
//                    var restore = false
//                    index = line.index(after: index)
//                    // saved
//                    while index != line.endIndex, !restore {
//                        let ch = line[index]
//                        if let opt = options[String(ch)] {
//                            switch opt {
//                            case 1:
//                                // move Forward
//                                currentPosition = [
//                                    currentPosition[0] + currentDirection.x,
//                                    currentPosition[1] + currentDirection.y,
//                                    currentPosition[2] + currentDirection.z
//                                ]
//                                vertexes[currentVertexIndex].append(contentsOf: currentPosition)
//                            case 2:
//                                // rotate positive
////                                print(currentDirection.x, currentDirection.y)
//                                currentDirection.xy = currentDirection.xy.rotated(by: -1.0 * angle * .radiansPerDegree)
////                                print(currentDirection.x, currentDirection.y)
//                            case 3:
//                                // rotate positive
//                                currentDirection.xy = currentDirection.xy.rotated(by: angle * .radiansPerDegree)
//                            case 0:
//                                restore = true
//                            default: break
//                            }
//                        }
//                        if !restore {
//                            index = line.index(after: index)
//                        }
//                    }
//                    //restored
//                    currentPosition = savedPosition
//                    currentDirection = savedDirection
//                    if line.index(after: index) != line.endIndex {
//                        currentVertexIndex += 1
//                        vertexes.append([Float]())
//                        vertexes[currentVertexIndex].append(contentsOf: currentPosition)
//                    }
//
//                default: break
//                }
//            }
//            index = line.index(after: index)
//        }
        
        return recur(line: line, indx: line.startIndex, position: from, direction: direction, angle: angle).0
    }
    
    func recur(line: String, indx: String.Index, position: [Float], direction: Vector3, angle: Float) -> ([[Float]], String.Index) {
        var index = indx
        var currentDirection = direction
        var currentPosition = position
        var vertexes = [[Float]]()
        var currentVertexIndex = 0
        vertexes.append([Float]())
        vertexes[0].append(contentsOf: currentPosition)
        while index != line.endIndex {
            let ch = line[index]
            if let opt = options![String(ch)] {
                switch opt {
                case 1:
                    // move Forward
                    currentPosition = [
                        currentPosition[0] + currentDirection.x,
                        currentPosition[1] + currentDirection.y,
                        currentPosition[2] + currentDirection.z
                    ]
                    vertexes[currentVertexIndex].append(contentsOf: currentPosition)
                case 2: currentDirection.xy = currentDirection.xy.rotated(by: -1.0 * angle * .radiansPerDegree)
                case 3: currentDirection.xy = currentDirection.xy.rotated(by: angle * .radiansPerDegree)
                case 4: currentDirection.xz = currentDirection.xz.rotated(by: -1.0 * angle * .radiansPerDegree)
                case 5: currentDirection.xz = currentDirection.xz.rotated(by: angle * .radiansPerDegree)
                case 6: currentDirection.yz = currentDirection.yz.rotated(by: -1.0 * angle * .radiansPerDegree)
                case 7: currentDirection.yz = currentDirection.yz.rotated(by: angle * .radiansPerDegree)
                case 0:
                    if vertexes[currentVertexIndex].count == 3 {
                        vertexes.remove(at: currentVertexIndex)
                        currentVertexIndex -= 1
                    }
                    let r = recur(line: line, indx: line.index(after: index), position: currentPosition, direction: currentDirection, angle: angle)
                    index = r.1
                    for arr in r.0 {
                        vertexes.append(arr)
                        currentVertexIndex += 1
                    }
                    currentVertexIndex += 1
                    vertexes.append([Float]())
                    vertexes[currentVertexIndex].append(contentsOf: currentPosition)
                case -1:
                    if vertexes[currentVertexIndex].count == 3 {
                        vertexes.remove(at: currentVertexIndex)
                    }
                    return (vertexes, index)
                default: break
                }
            }
            index = line.index(after: index)
        }
        if vertexes[currentVertexIndex].count == 3 {
            vertexes.remove(at: currentVertexIndex)
        }
        return (vertexes, index)
    }
    
}
