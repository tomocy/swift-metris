// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Transform.h"
#include "Vertex.h"

namespace D3 {
namespace WithColor {
    struct Raster {
        Coordinate position [[position]] = { 0 };
        float4 color = { 0, 0, 0, 1 };
    };

    vertex Raster vertexMain(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex<::Vertex::Materials::Color>* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        const constant auto* v = &vs[id];

        auto position = v->toCoordinate();
        position = camera->withTransformed(position);

        return {
            .position = position,
            .color = v->material.color,
        };
    }

    fragment float4 fragmentMain(const Raster r [[stage_in]])
    {
        return r.color;
    }
}
}
