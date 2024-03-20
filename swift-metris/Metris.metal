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

vertex D3::Coordinate shadowMain(
    const RawVertex v [[stage_in]],
    constant D3::Matrix* const matrix [[buffer(1)]]
) {
    return *matrix * D3::Coordinate(v.position, 1);
}

struct Raster {
public:
    struct Positions {
    public:
        D3::Coordinate clip [[position]] = { 0, 0, 0, 0 };
        D3::Measure view = { 0, 0, 0 };
    };

public:
    Positions positions = {};
    D3::Measure normal = { 0, 0, 0 };
    float2 textureCoordinate = { 0, 0 };
};

vertex Raster vertexMain(
    const RawVertex v [[stage_in]],
    constant D3::Matrix* const transform [[buffer(1)]]
)
{
    auto position = D3::Coordinate(v.position, 1);
    position = *transform * position;

    auto normal = D3::Coordinate(v.normal, 0);
    normal = *transform * normal;

    return {
        .positions = {
            .clip = position,
            .view = v.position,
        },
        .normal = normal.xyz,
        .textureCoordinate = v.textureCoordinate,
    };
}

struct Lights {
public:
    struct Ambient {
    public:
        float intensity = 0;
    };

    struct Directional {
    public:
        float intensity = 0;
        D3::Matrix projection = {};
        D3::Measure direction = { 0, 0, 0 };
    };

public:
    Ambient ambient = {};
    Directional directional = {};
};

float3 lambertReflection(float3 light, float3 normal) {
    return metal::saturate(
        metal::dot(light, normal)
    );
}

float3 blinnPhongReflection(float3 light, float3 view, float3 normal, float3 exponent) {
    const auto halfway = metal::normalize(light + view);
    const auto reflect = metal::saturate(
        metal::dot(halfway, normal)
    );
    return metal::pow(reflect, exponent);
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
            float3 light;
            float3 view;
            float3 normal;
        } dirs = {
            .light = metal::normalize(-light.direction),
            .view = metal::normalize(-r.positions.view),
            .normal = metal::normalize(r.normal),
        };

        const auto diffuse = lambertReflection(dirs.light, dirs.normal);
        const auto specular = blinnPhongReflection(dirs.light, dirs.view, dirs.normal, 50);
        rgb += color.rgb * (diffuse + specular) * light.intensity;
    }

    return float4(rgb, color.a);
}
}
}
