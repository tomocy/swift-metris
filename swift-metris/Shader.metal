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

        positions.world = position;
        positions.view = view * positions.world;
        positions.clip = projection * positions.view;

        return positions;
    }

public:
    Matrix projection = {};
    Matrix view = {};
};

struct Model {
public:
    Matrix transform = {};
};

vertex Coordinate shadowMain(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]],
    constant Model* const model [[buffer(2)]]
)
{
    const auto inWorld = model->transform * Coordinate(v.position, 1);
    const auto positions = aspect->applyTo(inWorld);

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
    constant Aspect* const aspect [[buffer(1)]],
    constant Model* const model [[buffer(2)]]
)
{
    const auto inWorld = model->transform * Coordinate(v.position, 1);
    const auto positions = aspect->applyTo(inWorld);

    const auto normal = model->transform * Coordinate(v.normal, 0);

    return {
        .positions = positions,
        .normal = normal.xyz,
        .textureCoordinate = v.textureCoordinate,
    };
}

struct Lights {
public:
    struct Light {
    public:
        float3 color = { 1, 1, 1 };
        float intensity = 0;
        Aspect aspect = {};
    };

public:
    Light ambient = {};
    Light directional = {};
    Light point = {};
};

float measureShaded(const metal::depth2d<float> map, const Aspect light, const Coordinate position)
{
    constexpr auto sampler = metal::sampler(
        metal::coord::normalized,
        metal::address::clamp_to_edge,
        metal::filter::linear,
        metal::compare_func::greater_equal
    );

    const auto positions = light.applyTo(position);
    const auto inNDC = positions.clip.xyz / positions.clip.w;

    // Shift the origin from center (in NDC) to top-left (in texture).
    const auto coordinate = float2(
        inNDC.x * 0.5 + 0.5,
        -inNDC.y * 0.5 + 0.5
    );

    const auto bias = 5e-3f;
    return map.sample_compare(sampler, coordinate, inNDC.z - bias);
}

Measure lambertReflection(const Measure toLight, const Measure normal)
{
    return metal::saturate(
        metal::dot(toLight, normal)
    );
}

Measure measureDiffuse(const Measure toLight, const Measure normal)
{
    return lambertReflection(toLight, normal);
}

Measure blinnPhongReflection(
    const Measure toLight, const Measure toView, const Measure normal,
    const Measure exponent
)
{
    const auto halfway = metal::normalize(toLight + toView);
    const auto reflect = metal::saturate(
        metal::dot(halfway, normal)
    );
    return metal::pow(reflect, exponent);
}

Measure measureSpecular(const Measure toLight, const Measure toView, const Measure normal)
{
    return blinnPhongReflection(toLight, toView, normal, 50);
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
        rgb += color.rgb * light.color * light.intensity;
    }

    {
        const auto light = lights->directional;

        // TODO(tomocy): Fix
        // We know that for now
        // the light's direction, or the forward vector in view space is stored in view.rows[2].xyz.
        const auto lightDir = float3(
            light.aspect.view.columns[0][2],
            light.aspect.view.columns[1][2],
            light.aspect.view.columns[2][2]
        );

        const struct {
            float3 toLight;
            float3 toView;
            float3 normal;
        } dirs = {
            .toLight = metal::normalize(-lightDir),
            .toView = metal::normalize(-r.positions.view.xyz),
            .normal = metal::normalize(r.normal),
        };

        const auto howUnshaded = 1 - measureShaded(shadowMap, light.aspect, r.positions.world);

        const auto howDiffuse = measureDiffuse(dirs.toLight, dirs.normal) * howUnshaded;
        const auto howSpecular = measureSpecular(dirs.toLight, dirs.toView, dirs.normal) * howUnshaded;

        rgb += color.rgb * (howDiffuse + howSpecular) * light.color * light.intensity;
    }

    {
        const auto light = lights->point;

        // TODO(tomocy): Fix
        // We know that for now
        // the light's position in world is stored in view.columns[3].xyz.
        const auto lightPos = light.aspect.view.columns[3].xyz;

        const auto toLight = lightPos - r.positions.world.xyz;
        const auto distance = metal::dot(toLight, toLight);
        const auto attenuation = 1 / metal::max(distance, 1e-4);

        const struct {
            float3 toLight;
            float3 toView;
            float3 normal;
        } dirs = {
            .toLight = metal::normalize(toLight),
            .toView = metal::normalize(-r.positions.view.xyz),
            .normal = metal::normalize(r.normal),
        };

        const auto howDiffuse = measureDiffuse(dirs.toLight, dirs.normal) * attenuation;
        const auto howSpecular = measureSpecular(dirs.toLight, dirs.toView, dirs.normal) * attenuation;

        rgb += color.rgb * (howDiffuse + howSpecular) * light.color * light.intensity;
    }

    return float4(rgb, color.a);
}
}
}
