// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Transform.h"
#include "Vertex.h"

namespace D3 {
namespace WithTexture {
    struct Raster {
    public:
        Coordinate position [[position]] = { 0, 0, 0, 1 };
        float2 textureCoordinate = { 0, 0 };
    };

    vertex Raster vertexMain(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex<::Vertex::Materials::Texture>* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        constant auto* const v = &vs[id];

        auto position = v->toCoordinate();
        position = camera->withTransformed(position);

        return {
            .position = position,
            .textureCoordinate = v->material.coordinate,
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
