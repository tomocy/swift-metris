// tomocy

#pragma once

#include "Dimension.h"
#include "Transform.h"

namespace D3 {
template <typename M>
struct Vertex {
public:
    using Material = M;

public:
    Coordinate toCoordinate(const float w = 1) const constant
    {
        return withTransformed(Coordinate(position, w));
    }

    Coordinate withTransformed(const Coordinate position) const constant
    {
        return transform.apply(position);
    }

public:
    Measure position = { 0, 0, 0 };
    Material material = {};
    Transform transform = {};
};
}
