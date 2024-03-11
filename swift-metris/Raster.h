// tomocy

#pragma once

#include "Dimension.h"

struct Raster {
    D3::Coordinate position [[position]] = {0};
    float4 color = {0, 0, 0, 1};
};
