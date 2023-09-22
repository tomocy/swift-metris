// tomocy

import Metal

struct Metris {
    static func describe(to descriptor: MTLRenderPipelineDescriptor, with device: MTLDevice) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }

    func encode(with encoder: MTLRenderCommandEncoder) {
        do {
            let camera = Camera(
                projection: Transform2D.orthogonal(
                    top: Float(size.height), bottom: 0,
                    left: 0, right: Float(size.width)
                ),
                transform: Transform2D(
                    translate: SIMD2(0, 0)
                )
            )
            camera.encode(with: encoder, at: 0)
        }

        do {
            let field = Metris.Field(width: 5, height: 8)

            var primitive = IndexedPrimitive()

            for y in 0..<field.height {
                for x in 0..<field.width {
                    if (!field.get(x: x, y: y)) {
                        continue
                    }

                    var rect = Rectangle(
                        size: CGSize(width: 94, height: 94)
                    )

                    rect.transform.translate.x = Float(100 * x) + 50
                    rect.transform.translate.y = Float(100 * y) + 50

                    rect.append(to: &primitive)
                }
            }

            primitive.encode(with: encoder, at: 1)
        }
    }

    let size: CGSize
}
