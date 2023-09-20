// tomocy

#pragma once

#include <metal_stdlib>

struct Transform2D {
public:
    float3 apply(float3 position) const constant {
        const auto transform = *this;
        return transform.apply(position);
    }

    float3 apply(float3 position) const {
        const auto t = metal::float3x3(
            float3(1, 0, 0),
            float3(0, 1, 0),
            float3(translate.x, translate.y, 1)
        );

        auto r = metal::float3x3(1);
        {
            const float s = metal::sin(rotate);
            const float c = metal::cos(rotate);
            r = metal::float3x3(
                float3(c, s, 0),
                float3(-s, c, 0),
                float3(0, 0, 1)
            );
        }

        const auto s = metal::float3x3(
            float3(scale.x, 0, 0),
            float3(0, scale.y, 0),
            float3(0, 0, 1)
        );

        position = s * position;
        position = r * position;
        position = t * position;

        return position;
    }

    float2 translate;
    float rotate;
    float2 scale;
};
