// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Material.h"
#include "Raster.h"
#include "Transform.h"
#include "Vertex.h"

namespace D3 {
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
        .material = v->material,
    };
}

fragment float4 fragmentMain(
    const Raster r [[stage_in]],
    const metal::texture2d<float> diffuse [[texture(0)]]
)
{
    constexpr auto sampler = metal::sampler(
        metal::mag_filter::linear,
        metal::min_filter::linear
    );

    return diffuse.sample(sampler, r.material.diffuse.coordinate);
}
}
