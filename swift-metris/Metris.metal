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
struct Vertex {
public:
    struct Raw {
    public:
        Measure position [[attribute(0)]] = { 0, 0, 0 };
        Measure normal [[attribute(1)]] = { 0, 0, 0 };
        float2 textureCoordinate [[attribute(2)]] = { 0, 0 };
    };
};

struct Aspect {
public:
    Matrix projection = {};
    Matrix transform = {};
};

vertex Coordinate shadowMain(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]]
)
{
    const auto position = aspect->transform * Coordinate(v.position, 1);
    return aspect->projection * position;
}

struct Raster {
public:
    struct Positions {
    public:
        Coordinate clip [[position]] = { 0, 0, 0, 0 };
        Measure view = { 0, 0, 0 };
    };

public:
    Positions positions = {};
    Measure normal = { 0, 0, 0 };
    float2 textureCoordinate = { 0, 0 };
};

vertex Raster vertexMain(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]]
)
{
    const auto position = aspect->transform * Coordinate(v.position, 1);
    const auto normal = aspect->transform * Coordinate(v.normal, 0);

    return {
        .positions = {
            .clip = aspect->projection * position,
            .view = position.xyz,
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
        Matrix projection = {};
        Matrix transform = {};
    };

public:
    Ambient ambient = {};
    Directional directional = {};
};

float3 lambertReflection(float3 light, float3 normal)
{
    return metal::saturate(
        metal::dot(light, normal)
    );
}

float3 blinnPhongReflection(float3 light, float3 view, float3 normal, float3 exponent)
{
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
)
{
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
            .light = metal::normalize(-light.transform.columns[2].xyz),
            .view = metal::normalize(-r.positions.view),
            .normal = metal::normalize(r.normal),
        };

        const auto howDiffuse = lambertReflection(dirs.light, dirs.normal);
        const auto howSpecular = blinnPhongReflection(dirs.light, dirs.view, dirs.normal, 50);

        rgb += color.rgb * (howDiffuse + howSpecular) * light.intensity;
    }

    return float4(rgb, color.a);
}
}
}
