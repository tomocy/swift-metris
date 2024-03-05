// tomocy

#pragma once

#include "Transform.h"

struct Camera {
public:
    float3 applyTransformTo(const float3 position) const constant {
        auto result = position;
        result = transform.apply(result);
        result = projection.apply(result);
        return result;
    }

public:
    Transform2D projection = {};
    Transform2D transform = {};
};
