// tomocy

#pragma once

#include "Transform.h"

struct Camera3D {
public:
    float4 applyTransformTo(const float4 position) const constant {
        auto result = position;
        result = transform.apply(result);
        result = projection.apply(result);
        return result;
    }

public:
    Transform3D projection = {};
    Transform3D transform = {};
};
