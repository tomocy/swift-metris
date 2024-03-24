// tomocy

import CoreGraphics
import ModelIO
import Metal

extension MetrisX {
    struct Mino {
        var pieces: [Piece]
        var position: SIMD2<Int>
    }
}

extension MetrisX.Mino {
    /// Complexity: O(pieces)
    var size: SIMD2<UInt> {
        let boundary = boundary
        let size = SIMD2.init(
            boundary.x.upperBound - boundary.x.lowerBound + 1,
            boundary.y.upperBound - boundary.y.lowerBound + 1
        )
        assert(size.x >= 0 && size.y >= 0)

        return .init(size)
    }

    /// Complexity: O(pieces)
    var boundary: Vector2D<ClosedRange<Int>> {
        let (min, max) = pieces.reduce((
            min: SIMD2.init(0, 0),
            max: SIMD2.init(0, 0)
        )) { current, piece in
            return (
                current.min.min(piece.position),
                current.max.max(piece.position)
            )
        }

        return .init(
            x: min.x...max.x,
            y: min.y...max.y
        )
    }
}

extension MetrisX.Mino {
    func position(of piece: MetrisX.Piece) -> SIMD2<Int> { position &+ piece.position }

    mutating func place(at position: SIMD2<Int>) {
        self.position = position
    }

    mutating func place(by delta: SIMD2<Int>) {
        position &+= delta
    }
}

extension MetrisX.Mino {
    mutating func rotate() {
        let (sin, cos) = (/* sin(degree: -90) */ -1, /* cos(degree: -90) */ 0)

        for (i, piece) in pieces.enumerated() {
            let local = piece.position
            pieces[i].position = .init(
                local.x * cos - local.y * sin,
                local.x * sin + local.y * cos
            )
        }
    }
}

extension MetrisX.Mino {
    enum Shape : CaseIterable {
        case i, j, l, o, s, t, z

        static func random() -> Self {
            var generator = SystemRandomNumberGenerator()
            return .random(using: &generator)
        }

        static func random<Generator: RandomNumberGenerator>(using generator: inout Generator) -> Self {
            return .allCases.randomElement(using: &generator)!
        }
    }
}

extension MetrisX.Mino {
    static func generate(
        in shape: Shape,
        device: any MTLDevice,
        allocator: any MDLMeshBufferAllocator,
        size: CGVolume,
        color: CGColor,
        at position: SIMD2<Int> = .init(0, 0)
    ) -> Self {
        switch shape {
        case .i:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(-1, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(2, 0)),
                ],
                position: position
            )
        case .j:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 2)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(-1, 0)),
                ],
                position: position
            )
        case .l:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 2)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 0)),
                ],
                position: position
            )
        case .o:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 0)),
                ],
                position: position
            )
        case .s:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(-1, 0)),
                ],
                position: position
            )
        case .t:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(-1, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                ],
                position: position
            )
        case .z:
            return .init(
                pieces: [
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(-1, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 1)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(0, 0)),
                    .init(device: device, allocator: allocator, size: size, color: color, position: .init(1, 0)),
                ],
                position: position
            )
        }
    }
}
