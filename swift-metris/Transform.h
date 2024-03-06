// tomocy

#pragma once

#include <metal_stdlib>

struct Transform2D {
public:
    float4 apply(const float4 position) const constant
    {
        const auto transform = *this;
        return transform.apply(position);
    }

    float4 apply(const float4 position) const
    {
        auto result = position.xyz;

        // In MSL, matrix are constructed in column-major order.
        // Therefore in applying transformations,
        // you should proceed from right to left: scale, rotate and then translate.
        result = toScale() * result.xyz;
        result = toRotate() * result.xyz;
        result = toTranslate() * result.xyz;

        return float4(result, 1);
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
    enum class Axis {
        X,
        Y,
        Z,
    };

public:
    float4 apply(const float4 position) const constant
    {
        auto result = position;

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
