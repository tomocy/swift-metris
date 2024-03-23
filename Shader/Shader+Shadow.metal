// tomocy

#include "Shader+Geometry.h"
#include "Shader+Model.h"
#include "Shader+Vertex.h"

namespace D3 {
namespace Shadow {

vertex float4 vertexMain(
    const D3::Vertex::Attributed raw [[stage_in]],
    constant Aspect& aspect [[buffer(1)]],
    constant Model* const models [[buffer(2)]],
    const uint id [[instance_id]]
)
{
    constant auto& model = models[id];
    const auto v = Vertex::from(raw, aspect, model);

    return v.positions.inClip.value;
}

}
}
