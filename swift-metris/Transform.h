// tomocy

#pragma once

#include <metal_stdlib>

struct Transform2D {
public:
    float3 apply(const float3 position) const constant
    {
        const auto transform = *this;
        return transform.apply(position);
    }

    float3 apply(const float3 position) const
    {
        auto result = position;

        // In MSL, matrix are constructed in column-major order.
        // Therefore in applying transformations,
        // you should proceed from right to left: scale, rotate and then translate.
        result = toScale() * result;
        result = toRotate() * result;
        result = toTranslate() * result;

        return result;
    }

protected:
    metal::float3x3 toTranslate() const
    {
        return metal::float3x3(
            float3(1, 0, 0),
            float3(0, 1, 0),
            float3(translate.x, translate.y, 1)
        );
    }

    metal::float3x3 toRotate() const
    {
        const float s = metal::sin(rotate);
        const float c = metal::cos(rotate);
        return metal::float3x3(
            float3(c, -s, 0),
            float3(s, c, 0),
            float3(0, 0, 1)
        );
    }

    metal::float3x3 toScale() const
    {
        return metal::float3x3(
            float3(scale.x, 0, 0),
            float3(0, scale.y, 0),
            float3(0, 0, 1)
        );
    }

public:
    float2 translate = float2(0, 0);
    float rotate = 0;
    float2 scale = float2(0, 0);
};

struct Transform3D {
public:
    float3 translate = float3(0, 0, 0);
};
