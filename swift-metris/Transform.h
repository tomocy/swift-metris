// tomocy

#pragma once

#include "Dimension.h"
#include <metal_stdlib>

namespace D3 {
struct Transform {
public:
    float4 apply(const float4 position) const constant
    {
        auto result = position;

        // In MSL, matrix are constructed in column-major order.
        // Therefore in applying transformations,
        // you should proceed from right to left: scale, rotate and then translate.
        //
        result = toScale() * result;
        result = toRotateAround(Axis::Z) * result;
        result = toTranslate() * result;

        return result;
    }

protected:
    metal::float4x4 toTranslate() const constant
    {
        return metal::float4x4(
            float4(1, 0, 0, 0),
            float4(0, 1, 0, 0),
            float4(0, 0, 1, 0),
            float4(translate.x, translate.y, translate.z, 1)
        );
    }

    metal::float4x4 toRotateAround(const Axis axis) const constant
    {
        const float s = metal::sin(rotate.z);
        const float c = metal::cos(rotate.z);

        switch (axis) {
        case Axis::X:
            return metal::float4x4(
                float4(1, 0, 0, 0),
                float4(0, c, s, 0),
                float4(0, -s, c, 0),
                float4(0, 0, 0, 1)
            );
        case Axis::Y:
            return metal::float4x4(
                float4(c, 0, -s, 0),
                float4(0, 1, 0, 0),
                float4(s, 0, c, 0),
                float4(0, 0, 0, 1)
            );
        case Axis::Z:
            return metal::float4x4(
                float4(c, s, 0, 0),
                float4(-s, c, 0, 0),
                float4(0, 0, 1, 0),
                float4(0, 0, 0, 1)
            );
        }
    }

    metal::float4x4 toScale() const constant
    {
        return metal::float4x4(
            float4(scale.x, 0, 0, 0),
            float4(0, scale.y, 0, 0),
            float4(0, 0, scale.z, 0),
            float4(0, 0, 0, 1)
        );
    }

public:
    float3 translate = float3(0, 0, 0);
    float3 rotate = float3(0, 0, 0);
    float3 scale = float3(1, 1, 1);
};
};
