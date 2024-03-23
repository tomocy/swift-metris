// tomocy

#include "Shader+Geometry.h"
#include "Shader+Model.h"
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
    static Vertex from(const Attributed attributed, const Aspect aspect, const Model model)
    {
        return {
            .positions = aspect.applyTo(
                model.applyTo(float4(attributed.position, 1))
            ),
            .normal = model.applyTo(float4(attributed.normal, 0)),
            .texture = {
                .coordinate = attributed.textureCoordinate,
            },
        };
    }

public:
    Positions::WVC positions;
    Coordinates::InWorld normal;
    Texture::Reference texture;
};

}
