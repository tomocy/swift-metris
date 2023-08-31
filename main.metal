#include <metal_stdlib>


vertex float4 vertex_main(
    device const float2* const positions [[buffer(0)]],
    uint vertexID [[vertex_id]]
) {
    const float2 position = positions[vertexID];
    return float4(position, 0.0, 1.0);
}

fragment float4 fragment_main() { return float4(1.0, 0.0, 0.0, 1.0); }
