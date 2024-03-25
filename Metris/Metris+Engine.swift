// tomocy

import AppKit
import ModelIO
import Metal

extension Metris {
    class Engine {
        init(
            device: any MTLDevice,
            allocator: any MDLMeshBufferAllocator,
            size: CGSize
        ) {
            self.device = device
            self.allocator = allocator

            self.size = size

            ticker = .init(interval: 0.875)
            field = .init(size: .init(10, 20))
        }

        deinit {
            stop()
        }

        let device: any MTLDevice
        let allocator: any MDLMeshBufferAllocator

        let size: CGSize

        private var ticker: Ticker
        private var field: Field
        private var mino: Mino?
    }
}

extension Metris.Engine {
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

        Engine.Log.log("Metris: Game over")
        stop()
    }
}

extension Metris.Engine {
    private func spawnMino() -> Bool {
        let size: CGFloat = size.min() / .init(field.size.min())

        var mino = Metris.Mino.generate(
            in: .random(),
            device: device,
            allocator: allocator,
            size: .init(width: size, height: size, depth: size),
            color: .random(
                red: .random(in: 0.4...0.8),
                green: .random(in: 0.4...0.8),
                blue: .random(in: 0.4...0.8),
                alpha: 0.8
            )
        )

        do {
            let range = field.positionRange(for: mino.boundary)
            mino.position = .init(
                .random(in: range.x),
                range.y.upperBound
            )
        }

        self.mino = nil
        return placeMino(mino)
    }

    private func placeMino(_ mino: Metris.Mino) -> Bool {
        var nextField = field

        if let mino = self.mino {
            nextField.clearMino(mino)
        }

        let placed = nextField.placeMino(mino)
        if !placed {
            return false
        }

        field = nextField
        self.mino = mino

        return true
    }
}

extension Metris.Engine {
    func encode(in context: some Shader.RenderContext) {
        field.encode(in: context)
    }
}

extension Metris.Engine {
    func keyDown(with event: NSEvent) {
        guard let chars = event.charactersIgnoringModifiers else { return }
        guard !chars.isEmpty else { return }

        let command = chars.first!.lowercased()

        if let input = Metris.Engine.Input.Move.parse(command) {
            _ = processInput(input)
            return
        }

        if let input = Metris.Engine.Input.Rotate.parse(command) {
            _ = processInput(input)
        }
    }
}

extension Metris.Engine {
    func processInput(_ input: Input.Move) -> Bool {
        guard let mino = mino else { return false }

        return placeMino(
            Engine.Functional.init(mino).state({
                $0.place(by: input.delta)
            }).generate()
        )
    }
}

extension Metris.Engine {
    func processInput(_ input: Input.Rotate) -> Bool {
        guard let mino = mino else { return false }

        return placeMino(
            Engine.Functional.init(mino).state({
                $0.rotate()
            }).generate()
        )
    }
}

extension Metris.Engine {
    struct Input {}
}

extension Metris.Engine.Input {
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

extension Metris.Engine.Input.Move {
    static func parse(_ command: String) -> Self? {
        switch command {
        case "s":
            return .down
        case "a":
            return .left
        case "d":
            return .right
        default:
            return nil
        }
    }
}

extension Metris.Engine.Input {
    struct Rotate {
        static var being: Self { .init() }
    }
}

extension Metris.Engine.Input.Rotate {
    static func parse(_ command: String) -> Self? {
        switch command {
        case "f":
            return .being
        default:
            return nil
        }
    }
}
