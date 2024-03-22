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
