// tomocy

#pragma once

#include "Transform.h"

struct Vertex2D {
public:
    float3 resolvePosition(const float z) const constant {
        return applyTransformTo(float3(position, z));
    }

    float3 applyTransformTo(const float3 position) const constant {
        return transform.apply(position);
    }


public:
    float2 position = float2(0, 0);
    float4 color = float4(0, 0, 0, 1);
    Transform2D transform = {};
};

struct Vertex3D {
public:
    float3 resolvePosition() const constant {
        return applyTransformTo(position);
    }

    float3 applyTransformTo(const float3 position) const constant {
        return transform.apply(position);
    }

public:
    float3 position = float3(0, 0, 0);
    float4 color = float4(0, 0, 0, 1);
    Transform3D transform = {};
};
