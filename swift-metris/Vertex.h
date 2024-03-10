// tomocy

#pragma once

#include "Transform.h"

namespace D3 {
struct Vertex {
public:
    Coordinate toCoordinate(const float w = 1) const constant {
        return withTransformed(Coordinate(position, w));
    }

    Coordinate withTransformed(const Coordinate position) const constant {
        return transform.apply(position);
    }

public:
    Measure position = { 0, 0, 0 };
    float4 color = float4(0, 0, 0, 1);
    Transform transform = {};
};
}
