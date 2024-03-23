// tomocy

#pragma once

#include "Shader+Geometry.h"

namespace D3 {

struct Model {
public:
    Coordinates::InWorld applyTo(const float4 position) const constant
    {
        return { .value = transform * position };
    }

public:
    float4x4 transform;
};

}
