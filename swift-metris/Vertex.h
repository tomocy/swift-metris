// tomocy

#pragma once

#include "Transform.h"

namespace D3 {
struct Vertex {
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
    Transform transform = {};
};
};
