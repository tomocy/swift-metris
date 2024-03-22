// tomocy

#pragma once

namespace D3 {

struct Light {
public:
    float3 color;
    float intensity;
    Aspect aspect;
};

struct Lights {
public:
    Light ambient;
    Light directional;
    Light point;
};

}
