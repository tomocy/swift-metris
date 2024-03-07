// tomocy

#pragma once

#include "Dimension.h"

struct Fragment {
    D3::Coordinate position [[position]] = { 0 };
    float4 color = float4(0);
};
