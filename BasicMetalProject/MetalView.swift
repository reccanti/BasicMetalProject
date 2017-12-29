//
//  MetalView.swift
//  BasicMetalProject
//
//  Created by Benjamin Wilcox on 12/29/17.
//  Copyright © 2017 Benjamin Wilcox. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
    
    func render() {
        device = MTLCreateSystemDefaultDevice()
        
        // initialize the points of the triangle
        let vertex_data:[Float] = [-1.0, -1.0, 0.0, 1.0,
                                    1.0, -1.0, 0.0, 1.0,
                                    0.0,  1.0, 0.0, 1.0]
        let data_size = vertex_data.count * MemoryLayout<Float>.size
        let vertex_buffer = device!.makeBuffer(bytes: vertex_data, length: data_size, options: [])
        
        // create a library of functions
        let library = device!.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: "vertex_func")
        let frag_func = library.makeFunction(name: "fragment_func")
        
        // create a render pipeline descriptor
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // create render pipeline state based on the descriptor
        let rps = try! device!.makeRenderPipelineState(descriptor: rpld)
        
        if let rpd = currentRenderPassDescriptor, let drawable = currentDrawable {
            rpd.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
            let command_buffer = device!.makeCommandQueue()?.makeCommandBuffer()
            let command_encoder = command_buffer?.makeRenderCommandEncoder(descriptor: rpd)
            
            // pass instructions for drawing the triangle to the encoder
            command_encoder?.setRenderPipelineState(rps)
            command_encoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            command_encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            
            command_encoder?.endEncoding()
            command_buffer?.present(drawable)
            command_buffer?.commit()
        }
    }
}
