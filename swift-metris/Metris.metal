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
    constant Vertex* const vertices [[buffer(1)]],
    const uint id [[vertex_id]]
)
{
    constant auto* const v = &vertices[id];

    auto position = v->toCoordinate();
    position = camera->withTransformed(position);

    return {
        .position = position,
        .material = v->material,
    };
}

fragment float4 fragmentMain(
    const Raster raster [[stage_in]],
    const Material::Source material
)
{
    constexpr auto sampler = metal::sampler(
        metal::mag_filter::nearest,
        metal::min_filter::nearest
    );

    return material.diffuse.sample(sampler, raster.material.diffuse.coordinate);
}
}
