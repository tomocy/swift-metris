// tomocy

#include "Shader+Geometry.h"
#include "Shader+Model.h"
#include "Shader+Vertex.h"

namespace D3 {
namespace Shadow {

vertex float4 vertexMain(
    const D3::Vertex::Attributed v [[stage_in]],
    constant Aspect& aspect [[buffer(1)]],
    constant Model* const models [[buffer(2)]],
    const uint id [[instance_id]]
)
{
    constant auto& model = models[id];

    const auto inWorld = model.applyTo(float4(v.position, 1));
    const auto positions = aspect.applyTo(inWorld);

    return positions.inClip.value;
}

}
}
