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

struct WVCPositions {
public:
    Coordinate clip [[position]] = { 0, 0, 0, 0 };
    Coordinate view = { 0, 0, 0, 0 };
    Coordinate world = { 0, 0, 0, 0 };
};

struct Aspect {
public:
    WVCPositions applyTo(const Coordinate position) const constant
    {
        const auto v = *this;
        return v.applyTo(position);
    }

    WVCPositions applyTo(const Coordinate position) const
    {
        auto positions = WVCPositions();

        positions.world = model * position;
        positions.view = view * positions.world;
        positions.clip = projection * positions.view;

        return positions;
    }

public:
    Matrix projection = {};
    Matrix view = {};
    Matrix model = {};
};

vertex Coordinate shadowMain(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]]
)
{
    const auto positions = aspect->applyTo(Coordinate(v.position, 1));
    return positions.clip;
}

struct Raster {
public:
    WVCPositions positions = {};
    Measure normal = { 0, 0, 0 };
    float2 textureCoordinate = { 0, 0 };
};

vertex Raster vertexMain(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]]
)
{
    const auto positions = aspect->applyTo(Coordinate(v.position, 1));
    const auto normal = aspect->model * Coordinate(v.normal, 0);

    return {
        .positions = positions,
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
        Aspect aspect = {};
    };

public:
    Ambient ambient = {};
    Directional directional = {};
};

float howShaded(const metal::depth2d<float> map, const Aspect light, Coordinate position)
{
    constexpr auto sampler = metal::sampler(
        metal::coord::normalized,
        metal::address::clamp_to_edge,
        metal::filter::linear,
        metal::compare_func::greater_equal
    );

    const auto inClip = light.projection * light.view * position;

    const auto inNDC = inClip.xyz / inClip.w;

    auto coordinate = inNDC.xy * 0.5 + 0.5;
    coordinate.y = 1 - coordinate.y;

    const auto s = map.sample(sampler, coordinate);

    const auto bias = 5e-3f;
    const auto z = inNDC.z - bias;

    return z > s ? 1 : 0;
}

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
    const metal::depth2d<float> shadowMap [[texture(0)]],
    const metal::texture2d<float> colorTexture [[texture(1)]],
    const metal::sampler sampler [[sampler(0)]]
)
{
    const auto color = colorTexture.sample(sampler, r.textureCoordinate);

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
            .light = metal::normalize(
                -float3(
                    light.aspect.view.columns[0][2],
                    light.aspect.view.columns[1][2],
                    light.aspect.view.columns[2][2]
                )
            ),
            .view = metal::normalize(-r.positions.view.xyz),
            .normal = metal::normalize(r.normal),
        };

        const auto howUnshaded = 1 - howShaded(shadowMap, light.aspect, r.positions.world);

        const auto howDiffuse = lambertReflection(dirs.light, dirs.normal) * howUnshaded;
        const auto howSpecular = blinnPhongReflection(dirs.light, dirs.view, dirs.normal, 50) * howUnshaded;

        rgb += color.rgb * (howDiffuse + howSpecular) * light.intensity;
    }

    return float4(rgb, color.a);
}
}
}
