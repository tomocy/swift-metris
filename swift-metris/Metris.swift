// tomocy

import Metal

class Metris {
    struct Descriptor {
        var piece: Piece.Descriptor
    }

    init(size: CGSize) {
        self.size = size

        ticker = Ticker(interval: 0.875)

        camera = Camera(
            projection: Transform2D.orthogonal(
                top: Float(size.height), bottom: 0,
                left: 0, right: Float(size.width)
            ),
            transform: Transform2D(
                translate: .init(0, 0)
            )
        )

        field = Field(size: .init(10, 20))

        do {
            let unit = min(
                size.width / CGFloat(field.size.x),
                size.height / CGFloat(field.size.y)
            )
            descriptor = .init(
                piece: .init(
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
            .random(),
            descriptor: descriptor.piece.colorized(
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

extension Metris.Input {
    struct Move : Equatable {
        static var down: Self { .init(delta: .init(0, -1)) }
        static var left: Self { .init(delta: .init(-1, 0)) }
        static var right: Self { .init(delta: .init(1, 0)) }

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
