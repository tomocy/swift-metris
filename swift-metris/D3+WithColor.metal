// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Transform.h"

namespace D3 {
namespace WithColor {
    struct Vertex {
    public:
        Coordinate toCoordinate(const float w = 1) const constant {
            return withTransformed(Coordinate(position, w));
        }

        Coordinate withTransformed(const Coordinate position) const constant {
            return transform.apply(position);
        }

    public:
        Measure position = {0, 0, 0};
        float4 color = {0, 0, 0, 1};
        Transform transform = {};
    };

    struct Raster {
        Coordinate position [[position]] = {0};
        float4 color = {0, 0, 0, 1};
    };

    vertex Raster vertexMain(
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

    fragment float4 fragmentMain(const Raster r [[stage_in]]) {
        return r.color;
    }
}
}
