// tomocy

#pragma once

#include <metal_stdlib>

namespace D3 {

enum class Axis {
    X,
    Y,
    Z,
};

using Measure = float3;
using Coordinate = float4;
using Matrix = metal::float4x4;

}

namespace D3 {
namespace Positions {

struct InNDC {
public:
    Measure value;
};

struct InClip {
public:
    Coordinate value [[position]];
};

struct InView {
public:
    Coordinate value;
};

struct InWorld {
public:
    Coordinate value;
};

struct WVC {
public:
    InNDC inNDC() const constant { return { .value = inClip.value.xyz / inClip.value.w }; }

public:
    InWorld inWorld;
    InView inView;
    InClip inClip;
};

}
}

namespace D3 {

struct Aspect {
public:
    Positions::WVC applyTo(const constant Positions::InWorld& position) const constant
    {
        auto positions = Positions::WVC();

        positions.inWorld = position;
        positions.inView = { .value = view * positions.inWorld.value };
        positions.inClip = { .value = projection * positions.inView.value };

        return positions;
    }

public:
    Matrix projection;
    Matrix view;
};

}
