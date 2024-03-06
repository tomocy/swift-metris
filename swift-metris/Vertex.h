// tomocy

#pragma once

#include "Transform.h"

struct Vertex2D {
public:
    float4 resolvePosition(const float z = 1, const float w = 1) const constant {
        return applyTransformTo(float4(position, z, w));
    }

    float4 applyTransformTo(const float4 position) const constant {
        return transform.apply(position);
    }


public:
    float2 position = float2(0, 0);
    float4 color = float4(0, 0, 0, 1);
    Transform2D transform = {};
};

struct Vertex3D {
public:
    float4 resolvePosition(const float w = 1) const constant {
        return applyTransformTo(float4(position, w));
    }

    float4 applyTransformTo(const float4 position) const constant {
        return transform.apply(position);
    }

public:
    float3 position = float3(0, 0, 0);
    float4 color = float4(0, 0, 0, 1);
    Transform3D transform = {};
};
