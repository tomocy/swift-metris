// tomocy

#include "Camera.h"
#include "Fragment.h"
#include "Vertex.h"

namespace D3 {
    vertex Fragment shadeVertex(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        const constant auto* v = &vs[id];

        auto position = v->resolvePosition();
        position = camera->applyTransformTo(position);

        return {
            .position = position,
            .color = v->color,
        };
    }
}

namespace World3D {
    vertex Fragment shadeVertex(
        constant D3::Camera* const camera [[buffer(0)]],
        constant D3::Vertex* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        const constant auto* v = &vs[id];

        auto position = v->resolvePosition();
        position = camera->applyTransformTo(position);

        return {
            .position = position,
            .color = v->color,
        };
    }
}

fragment float4 shadeFragment(const Fragment f [[stage_in]]) {
    return f.color;
}
