// tomocy

#pragma once

#include "Dimension.h"

struct Raster {
    D3::Coordinate position [[position]] = { 0 };
    float4 color = float4(0);
};
