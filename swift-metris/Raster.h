// tomocy

#pragma once

#include "Dimension.h"

namespace D3 {
template <typename M>
struct Raster {
public:
    using Material = M;

public:
    Coordinate position [[position]] = { 0, 0, 0, 1 };
    Material material = {};
};
}
