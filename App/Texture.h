// tomocy

#pragma once

namespace Texture {
template <typename P>
using Source = metal::texture2d<P>;

struct Reference {
public:
    float2 coordinate = { 0, 0 };
};
}
