// tomocy

import Foundation
import Metal

class Metris {
    struct Descriptor {
        var piece: Piece.Descriptor
    }

    init(size: CGSize) {
        self.size = size

        ticker = Ticker(interval: 1.0)

        camera = Camera(
            projection: Transform2D.orthogonal(
                top: Float(size.height), bottom: 0,
                left: 0, right: Float(size.width)
            ),
            transform: Transform2D(
                translate: SIMD2(0, 0)
            )
        )

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

    deinit {
        stop()
    }

    let size: CGSize
    let descriptor: Descriptor

    private var ticker: Ticker

    private var camera: Camera
    private var field: Field

    private var currentMino: Mino?
}

extension Metris {
    struct Input {}

    func start() {
        ticker.start { [weak self] in
            guard let self = self else { return }
            self.commit()
        }

        spawnMino()
    }

    func stop() {
        ticker.stop()
    }

    func commit() {
        process(input: Input.Move.down())
    }

    private func spawnMino() {
        var mino = Mino.generate(.i, descriptor: descriptor.piece)
        let range = field.positionRange(for: mino.size)
        mino.position = SIMD2(
            .random(in: range.x),
            range.y.upperBound
        )

        place(mino: mino)
    }

    private func place(mino: Mino) {
        currentMino?.clear(on: &field)

        mino.place(on: &field)
        currentMino = mino
    }
}

extension Metris.Input {
    struct Move {
        static func down() -> Self { Self(delta: SIMD2(0, -1)) }
        static func left() -> Self { Self(delta: SIMD2(-1, 0)) }
        static func right() -> Self { Self(delta: SIMD2(1, 0)) }

        private init(delta: SIMD2<Int>) {
            self.delta = delta
        }

        let delta: SIMD2<Int>
    }
}

extension Metris {
    func process(input: Input.Move) {
        guard var mino = currentMino else { return }

        let nextField = field.cleared(mino: mino)

        mino.position &+= input.delta
        if mino.collides(on: nextField) {
            return
        }

        place(mino: mino)
    }
}

extension Metris.Input {
    struct Rotate {}
}

extension Metris {
    func process(input: Input.Rotate) {
        guard var mino = currentMino else { return }

        let nextField = field.cleared(mino: mino)

        mino.rotate()
        if mino.collides(on: nextField) {
            return
        }

        place(mino: mino)
    }
}

extension Metris {
    static func describe(to descriptor: MTLRenderPipelineDescriptor, with device: MTLDevice) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }

    func encode(with encoder: MTLRenderCommandEncoder) {
        camera.encode(with: encoder, at: 0)

        do {
            var primitive = IndexedPrimitive()
            field.append(to: &primitive)
            primitive.encode(with: encoder, at: 1)
        }
    }
}
