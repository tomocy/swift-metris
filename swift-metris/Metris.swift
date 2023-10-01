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

        camera = Camera(
            projection: Transform2D.orthogonal(
                top: Float(size.height), bottom: 0,
                left: 0, right: Float(size.width)
            ),
            transform: Transform2D(
                translate: SIMD2(0, 0)
            )
        )

        do {
            var mino = Mino.generate(.i, descriptor: descriptor.piece)
            let range = field.positionRange(for: mino.size)
            mino.position = SIMD2(
                .random(in: range.x),
                range.y.upperBound
            )

            place(mino: mino)
        }
    }

    func encode(with encoder: MTLRenderCommandEncoder) {
        camera.encode(with: encoder, at: 0)

        do {
            var primitive = IndexedPrimitive()
            field.append(to: &primitive)
            primitive.encode(with: encoder, at: 1)
        }
    }

    mutating func moveMino(by delta: SIMD2<Int>) {
        guard var mino = currentMino else { return }

        let nextField = field.cleared(mino: mino)

        mino.position &+= delta
        if mino.collides(on: nextField) {
            return
        }

        place(mino: mino)
    }

    mutating func rotateMino() {
        guard var mino = currentMino else { return }

        let nextField = field.cleared(mino: mino)

        mino.rotate()
        if mino.collides(on: nextField) {
            return
        }

        place(mino: mino)
    }

    mutating func place(mino: Mino) {
        currentMino?.clear(on: &field)

        mino.place(on: &field)
        currentMino = mino
    }

    let size: CGSize
    let descriptor: Descriptor

    var camera: Camera

    var field: Field
    var currentMino: Mino? = nil
}
