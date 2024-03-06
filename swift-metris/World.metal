// tomocy

#include "Camera.h"
#include "Fragment.h"
#include "Vertex.h"

namespace World3D {
    vertex Fragment shadeVertex(
        constant Camera3D* const camera [[buffer(0)]],
        constant Vertex3D* const vs [[buffer(1)]],
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
