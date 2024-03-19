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
    D3::Measure normal = { 0, 0, 0 };
    float2 textureCoordinate = { 0, 0 };
};

vertex Raster vertexMain(
    const RawVertex v [[stage_in]],
    constant D3::Matrix* const matrix [[buffer(1)]]
)
{
    auto position = D3::Coordinate(v.position, 1);
    position = *matrix * position;

    auto normal = D3::Coordinate(v.normal, 0);
    normal = *matrix * normal;

    return {
        .position = position,
        .normal = normal.xyz,
        .textureCoordinate = v.textureCoordinate,
    };
}

struct Lights {
public:
    struct Ambient {
        float intensity = 0;
    };

    struct Directional {
        float intensity = 0;
        float3 direction = { 0, 0, 0 };
    };

public:
    Ambient ambient = {};
    Directional directional = {};
};

float3 lambertReflection(float3 normal, float3 light) {
    return metal::saturate(
        metal::dot(normal, light)
    );
}

fragment float4 fragmentMain(
    const Raster r [[stage_in]],
    constant Lights* const lights [[buffer(0)]],
    const metal::sampler sampler [[sampler(0)]],
    const metal::texture2d<float> texture [[texture(0)]]
) {
    const auto color = texture.sample(sampler, r.textureCoordinate);

    float3 rgb = 0;

    {
        const auto light = lights->ambient;
        rgb += color.rgb * light.intensity;
    }

    {
        const auto light = lights->directional;

        const struct {
            float3 normal;
            float3 light;
        } dirs = {
            .normal = metal::normalize(r.normal),
            .light = metal::normalize(-light.direction),
        };

        rgb += color.rgb * lambertReflection(dirs.normal, dirs.light) * light.intensity;
    }

    return float4(rgb, color.a);
}
}
}
