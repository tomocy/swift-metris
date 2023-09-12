#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float2 translate [[attribute(0)]];
    float rotate [[attribute(1)]];
    float2 scale [[attribute(2)]];
};

vertex float4 vertex_main(
    Vertex v [[stage_in]],
    constant float4x4& transform [[buffer(1)]]
) {
    const float4x4 translate = float4x4(
        float4(1, 0, 0, v.translate.x),
        float4(0, 1, 0, v.translate.y),
        float4(0, 0, 1, 0),
        float4(0, 0, 0, 1)
    );
    
    const float4x4 scale = float4x4(
        float4(v.scale.x, 0, 0, 0),
        float4(0, v.scale.y, 0, 0),
        float4(0, 0, 1, 0),
        float4(0, 0, 0, 1)
    );
    
    float4x4 rotate = float4x4(1);
    {
        const float s = sin(v.rotate);
        const float c = cos(v.rotate);
        rotate = float4x4(
            float4(c, -s, 0, 0),
            float4(s, c, 0, 0),
            float4(0, 0, 1, 0),
            float4(0, 0, 0, 1)
        );
    }
    

    return float4(0, 0, 0, 1) * translate * scale * rotate * transform;
}

fragment float4 fragment_main() { return float4(1.0, 0.0, 0.0, 1.0); }
