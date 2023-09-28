// tomocy

import Metal

struct Metris {
    static func describe(to descriptor: MTLRenderPipelineDescriptor, with device: MTLDevice) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }

    init(size: CGSize) {
        self.size = size

        field = Field(size: SIMD2(10, 20))

        do {
            let unit = min(
                size.width / CGFloat(field.size.x),
                size.height / CGFloat(field.size.y)
            )
            piece = Piece.Descriptor(
                size: CGSize(width: unit, height: unit),
                color: .random()
            )
        }
    }

    mutating func process() {
        let mino = Mino.generate(.i, descriptor: piece.colorized(with: .random()))
        mino.place(
            on: &field,
            at: SIMD2(
                .random(in: 0..<field.size.x-(mino.size.x - 1)),
                .random(in: 0..<field.size.y-(mino.size.y - 1))
            )
        )
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
            var primitive = IndexedPrimitive()
            field.append(to: &primitive)
            primitive.encode(with: encoder, at: 1)
        }
    }

    let size: CGSize
    var field: Field
    let piece: Piece.Descriptor
}
