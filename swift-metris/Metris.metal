// tomocy

#include "Camera.h"
#include "Fragment.h"
#include "Vertex.h"

vertex Fragment shadeVertex(
    constant Camera* const camera [[buffer(0)]],
    constant Vertex* const vs [[buffer(1)]],
    const uint id [[vertex_id]]
)
{
    const auto v = vs[id];

    auto position = float3(v.position, 1);

    position = v.transform.apply(position);

    position = camera->transform.apply(position);
    position = camera->projection.apply(position);

    return {
        .position = float4(position, 1),
        .color = float4(0, 0.9, 0.4, 1.0),
    };
}

fragment float4 shadeFragment(const Fragment f [[stage_in]]) {
    return f.color;
}
