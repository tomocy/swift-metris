// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Transform.h"

namespace D3 {
namespace WithTexture {
    struct Vertex {
    public:
        Coordinate toCoordinate(const float w = 1) const constant
        {
            return withTransformed(Coordinate(position, w));
        }

        Coordinate withTransformed(const Coordinate position) const constant
        {
            return transform.apply(position);
        }

    public:
        Measure position = { 0, 0, 0 };
        float2 textureCoordinate = { 0, 0 };
        Transform transform = {};
    };

    struct Raster {
    public:
        Coordinate position [[position]] = { 0, 0, 0, 1 };
        float2 textureCoordinate = { 0, 0 };
    };

    vertex Raster vertexMain(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        constant auto* const v = &vs[id];

        auto position = v->toCoordinate();
        position = camera->withTransformed(position);

        return {
            .position = position,
            .textureCoordinate = v->textureCoordinate,
        };
    }

    fragment float4 fragmentMain(
        const Raster r [[stage_in]],
        const metal::texture2d<float> texture [[texture(0)]]
    )
    {
        constexpr auto sampler = metal::sampler(
            metal::mag_filter::linear,
            metal::min_filter::linear
        );

        return texture.sample(sampler, r.textureCoordinate);
    }
}
}
