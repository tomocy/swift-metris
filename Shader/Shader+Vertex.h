// tomocy

#include "Shader+Dimension.h"
#include "Shader+Texture.h"

namespace D3 {

struct Vertex {
public:
    struct Attributed {
    public:
        Measure position [[attribute(0)]];
        Measure normal [[attribute(1)]];
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
    Measure position;
    Measure normal;
    Texture::Reference texture;
};

}
