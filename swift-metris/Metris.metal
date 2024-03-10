// tomocy

#include "Camera.h"
#include "Raster.h"
#include "Vertex.h"

namespace D3 {
    vertex Raster shadeVertex(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        const constant auto* v = &vs[id];

        auto position = v->toCoordinate();
        position = camera->withTransformed(position);

        return {
            .position = position,
            .color = v->color,
        };
    }
}

fragment float4 shadeFragment(const Raster r [[stage_in]]) {
    return r.color;
}
