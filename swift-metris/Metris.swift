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
            var field = Metris.Field(width: 5, height: 8)

            let mino = Metris.Mino(
                pieces: [SIMD2<UInt>(0, 0), SIMD2(1, 0), SIMD2(2, 0), SIMD2(3, 0)]
            )
            mino.put(on: &field, at: SIMD2<UInt>(0, 7))

            var primitive = IndexedPrimitive()
            field.append(to: &primitive)
            primitive.encode(with: encoder, at: 1)
        }
    }

    let size: CGSize
}
