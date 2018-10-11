//
//  ViewController.swift
//  HelloMetal2D
//
//  Created by Denis Dobynda on 16.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import Metal
import UIKit


class ViewController: UIViewController {

    var tree: LTreeGenerator?
    var scale: Float = 0.7
    var numberOfIterations = 2
    var cameraPosition = CGPoint(x: 0.0, y: -2.0)
    var zPosiiton: Float = -6.0
    
    var angleX: Float = 0.0
    var angleY: Float = 0.0
    var angleZ: Float = 0.0
    
    
    private var device: MTLDevice!
    private var layer: CAMetalLayer!

    private var pipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    
//    private let MEMORY_SIZE: Int = 4
    
//    private var timer: CADisplayLink!
    
    private var projectionMatrix: Matrix4!
    
    private var lines: [StripLine] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRender()
        initGestures()
        
//        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
//        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        render()
        
    }

    func initGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.respondToPanGesture(gesture:)))
        pan.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.respondToPinchGesture(gesture:)))
        self.view.addGestureRecognizer(pinch)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.respondToRotateGesture(gesture:)))
        self.view.addGestureRecognizer(rotate)
        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(gesture:)))
//        swipeLeft.direction = .left
//        self.view.addGestureRecognizer(swipeLeft)
    }
    
    private func initRender() {
        device = MTLCreateSystemDefaultDevice()
        layer = CAMetalLayer()
        layer.device = device
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true
        layer.frame = self.view.layer.frame
        self.view.layer.addSublayer(layer)
        
        let vertexes = load()
        for arr in vertexes {
            var vertex = [Vertex]()
            var i = 0
            while i < arr.count {
                let v = Vertex(x: arr[i], y: arr[i+1], z: arr[i+2], r: 0.0, g: 104.0/255.0, b: 5.0/255.0, a: 1.0)
                vertex.append(v)
                i += 3
            }
            let line = StripLine(name: "n", vertices: vertex, device: device)
            lines.append(line)
        }
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        commandQueue = device.makeCommandQueue()
    }
    
    private func render() {
        guard let drawable = layer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        let nodeModelMatrix = self.modelMatrix()
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(Float(cameraPosition.x), y: Float(cameraPosition.y), z: zPosiiton)
        nodeModelMatrix.multiplyLeft(worldModelMatrix)
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2, options: [])
        let bufferPointer = uniformBuffer?.contents()
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer! + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        lines.forEach { (line) in
            line.render(renderEncoder: renderEncoder, matrix1: uniformBuffer)
        }
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
//
//    @objc private func gameloop() {
//        autoreleasepool {
//            if (self.view == nil) {
//                timer.invalidate()
//            }
//            self.render()
//        }
//    }
    
    @objc func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        let v = gesture.velocity(in: view)
        if gesture.numberOfTouches == 1 {
            cameraPosition.x += (v.x / 1000.0) * CGFloat(scale)
            cameraPosition.y -= (v.y / 1000.0) * CGFloat(scale)
        } else if gesture.numberOfTouches == 2 {
            angleX += Float(v.y) / Float(view.bounds.maxY) * scale
            angleY += Float(v.x) / Float(view.bounds.maxX) * scale
        }
        render()
    }
    
    @objc func respondToPinchGesture(gesture: UIPinchGestureRecognizer) {
        scale *= Float(gesture.scale)
        gesture.scale = 1.0
        render()
    }
    
    @objc func respondToRotateGesture(gesture: UIRotationGestureRecognizer) {
        angleZ -= Float(gesture.rotation)
        gesture.rotation = 0.0
        render()
    }
    
    
    private func load() -> [[Float]] {
        guard let tree = tree else {return []}
        let options = [
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
        let parser = TurtleParser(tree.getLine(after: numberOfIterations), options: options)
        return parser.parse(starting: [0.0, -0.9, 0.0], direction: Vector3(0.0, 1.0, 0.0))!
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(0.0, y: -1.0, z: 0.0)
        matrix.rotateAroundX(angleX, y: angleY, z: angleZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }


}

