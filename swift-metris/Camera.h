// tomocy

#pragma once

#include "Dimension.h"
#include "Transform.h"

namespace D3 {
struct Camera {
public:
    Coordinate withTransformed(const Coordinate position) const constant {
        auto result = position;
        result = transform.apply(result);
        result = projection.apply(result);
        return result;
    }

public:
    Transform projection = {};
    Transform transform = {};
};
}
