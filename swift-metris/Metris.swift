// tomocy

import Metal

struct Metris {
    struct Descriptor {
        var piece: Piece.Descriptor
    }

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
            descriptor = Descriptor(
                piece: Piece.Descriptor(
                    size: CGSize(width: unit, height: unit),
                    color: .random()
                )
            )
        }
    }

    mutating func process() {
        defer { frames = (frames + 1) % 60 }

        if frames == 0 {
            currentMino = Mino.generate(
                .i,
                descriptor: descriptor.piece.colorized(with: .random())
            )

            let positionRange = field.positionRange(for: currentMino!.size)
            currentMino!.position = SIMD2(
                .random(in: positionRange.x),
                .random(in: positionRange.y)
            )
            currentMino!.place(on: &field)
            return
        }

        if let mino = currentMino, frames % 10 == 0 {
            mino.clear(on: &field)

            let delta: SIMD2<Int> = [SIMD2<Int>(0, -1), SIMD2<Int>(-1, 0), SIMD2<Int>(1, 0)].randomElement()!
            let range = field.positionRange(for: mino.size)
            currentMino!.position = mino.position.added(delta, in: range)

            currentMino!.place(on: &field)
        }
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
    let descriptor: Descriptor

    var field: Field
    var frames: UInt = 0
    var currentMino: Mino? = nil
}
