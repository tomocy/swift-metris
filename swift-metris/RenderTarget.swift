// tomocy

import Metal

struct RenderTarget {
    static func describe() -> MTLVertexDescriptor {
        let desc = MTLVertexDescriptor();

        Vertex.describe(to: desc, buffer: 0, layout: 0)

        return desc;
    }

    func encode(with encoder: MTLRenderCommandEncoder) {
        let camera = Camera(
            projection: Transform2D.orthogonal(
                top: Float(size.height), bottom: 0,
                left: 0, right: Float(size.width)
            ),
            transform: Transform2D(
                translate: SIMD2(0, 00)
            )
        )
        camera.encode(with: encoder, at: 1)

        var primitive = IndexedPrimitive()

        for y in 0..<8 {
            for x in 0..<5 {
                var rect = Rectangle(
                    size: CGSize(width: 94, height: 94)
                )

                rect.transform.translate.x = Float(100 * x) + 50
                rect.transform.translate.y = Float(100 * y) + 50

                rect.append(to: &primitive)
            }
        }

        primitive.encode(with: encoder, at: 0)
    }

    let size: CGSize
}

