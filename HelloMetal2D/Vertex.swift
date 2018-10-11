//
//  Vertex.swift
//  HelloMetal2D
//
//  Created by Denis Dobynda on 17.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import Foundation

struct Vertex{
    
    var x,y,z: Float
    var r,g,b,a: Float
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
}
