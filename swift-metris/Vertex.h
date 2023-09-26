// tomocy

#pragma once

#include "Transform2D.h"

struct Vertex {
    float2 position = float2(0, 0);
    float4 color = float4(0, 0, 0, 1);
    Transform2D transform = {};
};
