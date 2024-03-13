// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Material.h"
#include "Raster.h"
#include "Transform.h"
#include "Vertex.h"

namespace D3 {
namespace WithTexture {
    vertex Raster<Material::Texture> vertexMain(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex<Material::Texture>* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        constant auto* const v = &vs[id];

        auto position = v->toCoordinate();
        position = camera->withTransformed(position);

        return {
            .position = position,
            .material = v->material,
        };
    }

    fragment float4 fragmentMain(
        const Raster<Material::Texture> r [[stage_in]],
        const metal::texture2d<float> texture [[texture(0)]]
    )
    {
        constexpr auto sampler = metal::sampler(
            metal::mag_filter::linear,
            metal::min_filter::linear
        );

        return texture.sample(sampler, r.material.coordinate);
    }
}
}
