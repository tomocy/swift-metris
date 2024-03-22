// tomocy

#pragma once

#include "Shader+Geometry.h"

namespace D3 {

struct Model {
public:
    Measures::InWorld applyTo(const Coordinate position) const constant
    {
        return { .value = transform * position };
    }

public:
    Matrix transform;
};

}
