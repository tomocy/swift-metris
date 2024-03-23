// tomocy

#pragma once

#include "Shader+Geometry.h"
#include <metal_stdlib>

namespace D3 {
namespace Physics {
namespace Reflections {

struct Lambert {
public:
    static float3 measure(const float3 toLight, const float3 normal)
    {
        return metal::saturate(
            metal::dot(toLight, normal)
        );
    }
};

struct BlinnPhong {
public:
    static float3 measure(
        const float3 toLight,
        const float3 toView,
        const float3 normal,
        const float exponent
    )
    {
        const auto halfway = metal::normalize(toLight + toView);
        const auto reflect = metal::saturate(
            metal::dot(halfway, normal)
        );

        return metal::pow(reflect, exponent);
    }
};

}
}
}

namespace D3 {
namespace Physics {

struct Shade {
public:
    static float3 measure(const metal::depth2d<float> map, const Aspect aspect, const Coordinates::InWorld position)
    {
        constexpr auto sampler = metal::sampler(
            metal::coord::normalized,
            metal::address::clamp_to_edge,
            metal::filter::linear,
            metal::compare_func::greater_equal
        );

        const auto positions = aspect.applyTo(position);
        const auto inNDC = positions.inNDC();

        // Shift the origin from center (in NDC) to top-left (in texture).
        const auto coordinate = float2(
            inNDC.value.x * 0.5 + 0.5,
            -inNDC.value.y * 0.5 + 0.5
        );

        const auto bias = 5e-3f;
        return map.sample_compare(sampler, coordinate, inNDC.value.z - bias);
    }
};

struct Diffuse {
public:
    static float3 measure(const float3 toLight, const float3 normal)
    {
        return Reflections::Lambert::measure(toLight, normal);
    }
};

struct Specular {
public:
    static float3 measure(const float3 toLight, const float3 toView, const float3 normal)
    {
        return Reflections::BlinnPhong::measure(toLight, toView, normal, 50);
    }
};

}
}
