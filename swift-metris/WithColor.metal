// tomocy

#include "Camera.h"
#include "Dimension.h"
#include "Material.h"
#include "Raster.h"
#include "Transform.h"
#include "Vertex.h"

namespace D3 {
namespace WithColor {
    vertex Raster<Material::Color> vertexMain(
        constant Camera* const camera [[buffer(0)]],
        constant Vertex<Material::Color>* const vs [[buffer(1)]],
        const uint id [[vertex_id]]
    )
    {
        const constant auto* v = &vs[id];

        auto position = v->toCoordinate();
        position = camera->withTransformed(position);

        return {
            .position = position,
            .material = v->material,
        };
    }

    fragment float4 fragmentMain(const Raster<Material::Color> r [[stage_in]])
    {
        return r.material.value;
    }
}
}
