// tomocy

#include "Camera.h"
#include "Fragment.h"
#include "Vertex.h"

namespace World2D {
    vertex Fragment shadeVertex(
        constant Camera2D* const camera [[buffer(0)]],
        constant Vertex2D* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        const constant auto* v = &vs[id];

        auto position = v->resolvePosition(1);
        position = camera->applyTransformTo(position);

        return {
            .position = float4(position, 1),
            .color = v->color,
        };
    }
}

fragment float4 shadeFragment(const Fragment f [[stage_in]]) {
    return f.color;
}
