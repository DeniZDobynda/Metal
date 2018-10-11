//
//  Node.swift
//  HelloMetal2D
//
//  Created by Denis Dobynda on 17.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

class StripLine {
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice){
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
        
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder?, matrix1: MTLBuffer!){
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(matrix1!, offset: 0, index: 1)
        renderEncoder?.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
    }
    
}
