// tomocy

#pragma once

#include "Texture.h"

namespace Material {
struct Source {
public:
    Texture::Source<float> diffuse [[texture(0)]];
};

struct Reference {
public:
    Texture::Reference diffuse = {};
};
}
