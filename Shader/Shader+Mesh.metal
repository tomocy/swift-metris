// tomocy

#include "Shader+Geometry.h"
#include "Shader+Light.h"
#include "Shader+Model.h"
#include "Shader+Texture.h"
#include "Shader+Vertex.h"

namespace D3 {
namespace Mesh {

struct Raster {
public:
    struct Positions {
    public:
        float4 inWorld;
        float4 inView;
        float4 inClip [[position]];
    };

public:
    Positions positions;
    Coordinates::InWorld normal;
    Texture::Reference texture;
};

struct Material {
public:
    float4 sampleColorAt(const float2 coordinate) const
    {
        constexpr auto sampler = metal::sampler(
            metal::coord::normalized,
            metal::address::repeat,
            metal::filter::linear
        );

        return color.sample(sampler, coordinate);
    }

public:
    metal::depth2d<float> shadow [[texture(0)]];
    metal::texture2d<float> color [[texture(1)]];
};

}
}

namespace D3 {
namespace Mesh {

vertex Raster vertexMain(
    const Vertex::Attributed raw [[stage_in]],
    constant Aspect& aspect [[buffer(1)]],
    constant Model* models [[buffer(2)]],
    const uint id [[instance_id]]
)
{
    constant auto& model = models[id];
    const auto v = Vertex::from(raw, aspect, model);

    return {
        .positions = {
            .inWorld = v.positions.inWorld.value,
            .inView = v.positions.inView.value,
            .inClip = v.positions.inClip.value,
        },
        .normal = v.normal,
        .texture = v.texture,
    };
}

fragment float4 fragmentMain(
    const Raster r [[stage_in]],
    constant Lights& lights [[buffer(0)]],
    const Material material
)
{
    const Positions::WVC positions = {
        .inWorld = { .value = r.positions.inWorld },
        .inView = { .value = r.positions.inView },
        .inClip = { .value = r.positions.inClip },
    };

    const auto color = material.sampleColorAt(r.texture.coordinate);

    float3 rgb = 0;

    rgb += lights.ambient.applyTo(color.rgb);
    rgb += lights.directional.applyTo(color.rgb, material.shadow, positions, r.normal);
    rgb += lights.point.applyTo(color.rgb, positions, r.normal);

    return float4(rgb * color.a, color.a);
}

}
}
