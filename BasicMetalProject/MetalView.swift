//
//  MetalView.swift
//  BasicMetalProject
//
//  Created by Benjamin Wilcox on 12/29/17.
//  Copyright © 2017 Benjamin Wilcox. All rights reserved.
//

import MetalKit

// A struct that stores the position and color of the vertex
struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class MetalView: MTKView {
    
    var vertex_buffer: MTLBuffer!
    var rps: MTLRenderPipelineState! = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
    
    // create a buffer from vertex data
    func createBuffer() {
        let vertex_data = [Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
                           Vertex(position: [1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
                           Vertex(position: [0.0,  1.0, 0.0, 1.0], color: [0, 0, 1, 1])]
        vertex_buffer = device!.makeBuffer(bytes: vertex_data, length: MemoryLayout<Vertex>.size * 3, options: [])
    }
    
    // load the shaders and attach them to the render pipeline state
    func registerShaders() {
        
        // create a library of functions
        let library = device!.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: "vertex_func")
        let frag_func = library.makeFunction(name: "fragment_func")
        
        // create a render pipeline descriptor
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // update render pipeline state based on the descriptor
        do {
            try rps = device!.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            self.printView("\(error)")
        }
    }
    
    // send the rps that was generated to the GPU
    func sendToGPU() {
        if let rpd = currentRenderPassDescriptor, let drawable = currentDrawable {
            
            // clear screen with given background color
            rpd.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            
            // create a command buffer and encoder
            let command_buffer = device!.makeCommandQueue()?.makeCommandBuffer()
            let command_encoder = command_buffer?.makeRenderCommandEncoder(descriptor: rpd)
            
            // pass instructions for drawing the triangle to the encoder
            command_encoder?.setRenderPipelineState(rps)
            command_encoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            command_encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            
            // encode and present the drawable to the buffer?
            command_encoder?.endEncoding()
            command_buffer?.present(drawable)
            command_buffer?.commit()
        }
    }
    
    func render() {
        device = MTLCreateSystemDefaultDevice()
        createBuffer()
        registerShaders()
        sendToGPU()
    }
}
