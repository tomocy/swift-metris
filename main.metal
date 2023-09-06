#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
};

vertex float4 vertex_main(
    Vertex v [[stage_in]],
    constant float4x4& transform [[buffer(1)]]
) {
    return float4(v.position, 0.0, 1.0) * transform;
}

fragment float4 fragment_main() { return float4(1.0, 0.0, 0.0, 1.0); }
