// tomocy

#include "Shader+Geometry.h"
#include "Shader+Texture.h"

namespace D3 {

struct Vertex {
public:
    struct Attributed {
    public:
        float3 position [[attribute(0)]];
        float3 normal [[attribute(1)]];
        float2 textureCoordinate [[attribute(2)]];
    };

public:
    static Vertex from(const constant Attributed& attributed)
    {
        return {
            .position = attributed.position,
            .normal = attributed.normal,
            .texture = {
                .coordinate = attributed.textureCoordinate,
            },
        };
    }

public:
    float3 position;
    float3 normal;
    Texture::Reference texture;
};

}
