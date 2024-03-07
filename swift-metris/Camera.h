// tomocy

#pragma once

#include "Transform.h"

namespace D3 {
struct Camera {
public:
    float4 applyTransformTo(const float4 position) const constant {
        auto result = position;
        result = transform.apply(result);
        result = projection.apply(result);
        return result;
    }

public:
    Transform projection = {};
    Transform transform = {};
};
};

struct Camera3D {
public:
    float4 applyTransformTo(const float4 position) const constant {
        auto result = position;
        result = transform.apply(result);
        result = projection.apply(result);
        return result;
    }

public:
    D3::Transform projection = {};
    D3::Transform transform = {};
};
