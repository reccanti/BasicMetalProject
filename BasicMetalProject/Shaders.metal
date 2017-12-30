//
//  Shaders.metal
//  BasicMetalProject
//
//  Created by Benjamin Wilcox on 12/29/17.
//  Copyright © 2017 Benjamin Wilcox. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return vert.color;
}
