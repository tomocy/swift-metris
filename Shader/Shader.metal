// tomocy

#include "Shader+Dimension.h"
#include "Shader+Vertex.h"

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
    Measure inNDC() const { return inClip.xyz / inClip.w; }

public:
    Coordinate inClip [[position]] = { 0, 0, 0, 0 };
    Coordinate inView = { 0, 0, 0, 0 };
    Coordinate inWorld = { 0, 0, 0, 0 };
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

        positions.inWorld = position;
        positions.inView = view * positions.inWorld;
        positions.inClip = projection * positions.inView;

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

struct Raster {
public:
    WVCPositions positions = {};
    Measure normal = { 0, 0, 0 };
    float2 textureCoordinate = { 0, 0 };
};

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
}
}

namespace D3 {
namespace X {
float measureShaded(const metal::depth2d<float> map, const Aspect light, const Coordinate position)
{
    constexpr auto sampler = metal::sampler(
        metal::coord::normalized,
        metal::address::clamp_to_edge,
        metal::filter::linear,
        metal::compare_func::greater_equal
    );

    const auto positions = light.applyTo(position);
    const auto inNDC = positions.inNDC();

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
}
}

namespace D3 {
namespace X {
vertex Coordinate shadowVertex(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]],
    constant Model* const models [[buffer(2)]],
    const uint id [[instance_id]]
)
{
    constant auto* const model = &models[id];

    const auto inWorld = model->transform * Coordinate(v.position, 1);
    const auto positions = aspect->applyTo(inWorld);

    return positions.inClip;
}
}
}

namespace D3 {
namespace X {
vertex Raster meshVertex(
    const Vertex::Raw v [[stage_in]],
    constant Aspect* const aspect [[buffer(1)]],
    constant Model* const models [[buffer(2)]],
    const uint id [[instance_id]]
)
{
    constant auto* const model = &models[id];

    const auto inWorld = model->transform * Coordinate(v.position, 1);
    const auto positions = aspect->applyTo(inWorld);

    const auto normal = model->transform * Coordinate(v.normal, 0);

    return {
        .positions = positions,
        .normal = normal.xyz,
        .textureCoordinate = v.textureCoordinate,
    };
}

fragment float4 meshFragment(
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
            .toView = metal::normalize(-r.positions.inView.xyz),
            .normal = metal::normalize(r.normal),
        };

        const auto howUnshaded = 1 - measureShaded(shadowMap, light.aspect, r.positions.inWorld);

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

        const auto toLight = lightPos - r.positions.inWorld.xyz;
        const auto distance = metal::dot(toLight, toLight);
        const auto attenuation = 1 / metal::max(distance, 1e-4);

        const struct {
            float3 toLight;
            float3 toView;
            float3 normal;
        } dirs = {
            .toLight = metal::normalize(toLight),
            .toView = metal::normalize(-r.positions.inView.xyz),
            .normal = metal::normalize(r.normal),
        };

        const auto howDiffuse = measureDiffuse(dirs.toLight, dirs.normal) * attenuation;
        const auto howSpecular = measureSpecular(dirs.toLight, dirs.toView, dirs.normal) * attenuation;

        rgb += color.rgb * (howDiffuse + howSpecular) * light.color * light.intensity;
    }

    // Return alpha-premultiplied color.
    return float4(rgb * color.a, color.a);
}
}
}
