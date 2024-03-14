// tomocy

#pragma once

#include "Dimension.h"
#include "Material.h"

namespace D3 {
struct Raster {
public:
    Coordinate position [[position]] = { 0, 0, 0, 1 };
    Material material = {};
};
}
