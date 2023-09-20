#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float2 translate [[attribute(1)]];
    float rotate [[attribute(2)]];
    float2 scale [[attribute(3)]];
};

struct Camera {
    float3x3 projection;
    float3x3 transform;
};

vertex float4 shadeVertex(
    Vertex v [[stage_in]],
    constant Camera* const camera [[buffer(1)]]
) {
    // Matrices are constructed in column-major order.

    const auto translate = float3x3(
        float3(1, 0, 0),
        float3(0, 1, 0),
        float3(v.translate.x, v.translate.y, 1)
    );

    auto rotate = float3x3(1);
    {
        const float s = sin(v.rotate);
        const float c = cos(v.rotate);
        rotate = float3x3(
            float3(c, s, 0),
            float3(-s, c, 0),
            float3(0, 0, 1)
        );
    }

    const auto scale = float3x3(
        float3(v.scale.x, 0, 0),
        float3(0, v.scale.y, 0),
        float3(0, 0, 1)
    );

    auto position = float3(v.position, 1);
    position = scale * position;
    position = rotate * position;
    position = translate * position;
    
    position = camera->transform * position;
    position = camera->projection * position;

    return float4(position, 1);
}

fragment float4 shadeFragment() { return float4(0, 0.9, 0.4, 1.0); }
