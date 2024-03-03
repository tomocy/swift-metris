// tomocy

import Metal

class Metris {
    struct Descriptor {
        var piece: Piece.Descriptor
    }

    init(size: CGSize) {
        self.size = size

        ticker = .init(interval: 0.875)

        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            camera = .init(
                projection: .orthogonal(
                    top: halfSize.y, bottom: -halfSize.y,
                    left: -halfSize.x, right: halfSize.x
                ),
                transform: .init(
                    translate: halfSize
                )
            )
        }

        field = .init(size: .init(10, 20))

        do {
            let unit = min(
                size.width / .init(field.size.x),
                size.height / .init(field.size.y)
            )
            descriptor = .init(
                piece: .init(
                    size: .init(width: unit, height: unit),
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
    typealias Translate = SIMD2<Int>
}

extension Metris {
    func start() {
        ticker.start { [weak self] in
            guard let self = self else { return }
            self.commit()
        }

        commit()
    }

    func stop() {
        ticker.stop()
    }

    private func commit() {
        do {
            let placed = processInput(Input.Move.down)
            if placed {
                return
            }
        }

        field.clearLines()

        do {
            let placed = spawnMino()
            if placed {
                return
            }
        }

        Log.debug("Metris: Game over")
        stop()
    }

    private func spawnMino() -> Bool {
        var mino = Mino.generate(
            in: .random(),
            as: descriptor.piece.colorized(
                with: .random(
                    red: .random(in: 0...0.8),
                    green: .random(in: 0...0.8),
                    blue: .random(in: 0...0.8)
                )
            )
        )

        do {
            let range = field.positionRange(for: mino.boundary)
            mino.position = .init(
                .random(in: range.x),
                range.y.upperBound
            )
        }

        currentMino = nil
        return placeMino(mino)
    }

    private func placeMino(_ mino: Mino) -> Bool {
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

extension Metris {
    struct Input {}
}

extension Metris.Input {
    struct Move : Equatable {
        static var down: Self { .init(delta: .init(0, -1)) }
        static var left: Self { .init(delta: .init(-1, 0)) }
        static var right: Self { .init(delta: .init(1, 0)) }

        static func ==(left: Self, right: Self) -> Bool {
            return left.delta == right.delta
        }

        private init(delta: Metris.Translate) {
            self.delta = delta
        }

        let delta: Metris.Translate
    }
}

extension Metris {
    func processInput(_ input: Input.Move) -> Bool {
        guard let mino = currentMino else { return false }
        return placeMino(
            mino.positioned(by: input.delta)
        )
    }
}

extension Metris.Input {
    struct Rotate {
        static var being: Self { .init() }
    }
}

extension Metris {
    func processInput(_ input: Input.Rotate) -> Bool {
        guard let mino = currentMino else { return false }
        return placeMino(
            mino.rotated()
        )
    }
}

extension Metris {
    static func describe(to descriptor: MTLRenderPipelineDescriptor, with device: MTLDevice) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }
}

extension Metris: MTLFrameRenderCommandEncodable {
    func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        camera.encode(with: encoder, at: 0, in: frame)
        field.encode(with: encoder, at: 1, in: frame)
    }
}
