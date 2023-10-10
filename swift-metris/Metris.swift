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

    private func commit() {
        _ = process(input: Input.Move.down)
    }

    private func spawnMino() {
        var mino = Mino.generate(.i, descriptor: descriptor.piece)
        let range = field.positionRange(for: mino.size)
        mino.position = SIMD2(
            .random(in: range.x),
            range.y.upperBound
        )

        _ = place(mino: mino)
    }

    private func place(mino: Mino) -> Bool {
        var nextField = field
        currentMino?.clear(on: &nextField)

        let placed = mino.place(on: &nextField)
        if !placed {
            return false
        }

        field = nextField
        currentMino = mino

        return true
    }
}

extension Metris.Input {
    struct Move : Equatable {
        static var down: Self { Self(delta: SIMD2(0, -1)) }
        static var left: Self { Self(delta: SIMD2(-1, 0)) }
        static var right: Self { Self(delta: SIMD2(1, 0)) }

        static func ==(left: Self, right: Self) -> Bool {
            return left.delta == right.delta
        }

        private init(delta: SIMD2<Int>) {
            self.delta = delta
        }

        let delta: SIMD2<Int>
    }
}

extension Metris {
    func process(input: Input.Move) -> Bool {
        guard var mino = currentMino else { return false }

        mino.position &+= input.delta
        return place(mino: mino)
    }
}

extension Metris.Input {
    struct Rotate {}
}

extension Metris {
    func process(input: Input.Rotate) -> Bool {
        guard var mino = currentMino else { return false }

        mino.rotate()
        return place(mino: mino)
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
