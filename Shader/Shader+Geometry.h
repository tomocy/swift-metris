// tomocy

#pragma once

#include <metal_stdlib>

namespace D3 {

enum class Axis {
    X,
    Y,
    Z,
};

using float4x4 = metal::float4x4;

}

namespace D3 {
namespace Coordinates {

struct InNDC {
public:
    float3 value;
};

struct InClip {
public:
    float4 value [[position]];
};

struct InView {
public:
    float4 value;
};

struct InWorld {
public:
    float4 value;
};

}
}

namespace D3 {
namespace Positions {

struct WVC {
public:
    Coordinates::InNDC inNDC() const { return { .value = inClip.value.xyz / inClip.value.w }; }

public:
    Coordinates::InWorld inWorld;
    Coordinates::InView inView;
    Coordinates::InClip inClip;
};

}
}

namespace D3 {

struct Aspect {
public:
    Positions::WVC applyTo(const Coordinates::InWorld position) const
    {
        auto positions = Positions::WVC();

        positions.inWorld = position;
        positions.inView = { .value = view * positions.inWorld.value };
        positions.inClip = { .value = projection * positions.inView.value };

        return positions;
    }

public:
    float4x4 projection;
    float4x4 view;
};

}
