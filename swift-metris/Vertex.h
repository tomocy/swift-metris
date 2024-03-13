// tomocy

#pragma once

#include "Dimension.h"
#include "Transform.h"

namespace Vertex {
namespace Materials {
    struct Color {
    public:
        float4 color = { 0, 0, 0, 1 };
    };

    struct Texture {
    public:
        float2 coordinate = { 0, 0 };
    };
}
}

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
