// tomocy

import Metal

class Metris {
    init(with device: MTLDevice, for size: CGSize) {
        self.device = device

        ticker = .init(interval: 0.875)

        field = .init(for: .init(10, 20))

        do {
            let unit = min(
                size.width / .init(field.size.x),
                size.height / .init(field.size.y)
            )

            descriptor = .init(
                piece: .init(
                    size: .init(width: unit, height: unit, depth: unit / 2),
                    material: .init(
                        diffuse: Texture.Sources.Color.load(.black(), with: device)!
                    )
                )
            )
        }
    }

    deinit {
        stop()
    }

    let device: MTLDevice
    let descriptor: Descriptor

    private var ticker: Ticker

    private var field: Field
    private var currentMino: Mino?
}

extension Metris {
    struct Descriptor {
        var piece: Piece.Descriptor
    }
}

extension Metris {
    typealias Position = SIMD2<Int>
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
            as: descriptor.piece.materialized(
                with: .init(
                    diffuse: Texture.Sources.Color.load(
                        .random(
                            red: .random(in: 0...0.8),
                            green: .random(in: 0...0.8),
                            blue: .random(in: 0...0.8)
                        ),
                        with: device
                    )!
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

        if let mino = currentMino {
            nextField.clearMino(mino)
        }

        let placed = nextField.placeMino(mino)
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

        private init(delta: Metris.Position) {
            self.delta = delta
        }

        let delta: Metris.Position
    }
}

extension Metris {
    func processInput(_ input: Input.Move) -> Bool {
        guard let mino = currentMino else { return false }
        return placeMino(
            mino.placed(by: input.delta)
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

extension Metris: MTLFrameRenderCommandEncodableAsAt {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        as descriptor: MTLRenderPipelineDescriptor,
        at index: Int,
        in frame: MTLRenderFrame
    ) {
        field.encode(with: encoder, as: descriptor, at: index, in: frame)
    }
}
