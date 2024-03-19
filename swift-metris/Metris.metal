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

namespace D3 {
namespace X {
struct RawVertex {
public:
    D3::Measure position [[attribute(0)]] = { 0, 0, 0 };
    D3::Measure normal [[attribute(1)]] = { 0, 0, 0 };
    float2 textureCoordinate [[attribute(2)]] = { 0, 0 };
};

struct Raster {
public:
    D3::Coordinate position [[position]] = { 0, 0, 0 };
    float2 textureCoordinate = { 0, 0 };
};

vertex Raster vertexMain(
    const RawVertex v [[stage_in]],
    constant D3::Matrix* const matrix [[buffer(1)]]
)
{
    auto position = D3::Coordinate(v.position, 1);
    position = *matrix * position;

    return {
        .position = position,
        .textureCoordinate = v.textureCoordinate,
    };
}

struct Light {
public:
    float intensity = 0;
};

fragment float4 fragmentMain(
    const Raster r [[stage_in]],
    constant Light* const light [[buffer(0)]],
    const metal::sampler sampler [[sampler(0)]],
    const metal::texture2d<float> texture [[texture(0)]]
) {
    auto color = texture.sample(sampler, r.textureCoordinate);

    color *= light->intensity;

    return color;
}
}
}
