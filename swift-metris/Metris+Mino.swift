// tomocy

import CoreGraphics

extension Metris {
    struct Mino {
        var position: Position = .init(0, 0)
        private var pieces: [Piece]
    }
}

extension Metris.Mino {
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

extension Metris.Mino {
    mutating func place(at position: Metris.Position) {
        self.position = position
    }

    func placed(at position: Metris.Position) -> Self {
        var next = self
        next.place(at: position)
        return next
    }

    mutating func place(by delta: Metris.Position) {
        position &+= delta
    }

    func placed(by delta: Metris.Position) -> Self {
        var x = self
        x.place(by: delta)
        return x
    }

    func position(of piece: Metris.Piece) -> Metris.Position { position &+ piece.position }
}

extension Metris.Mino {
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

    func rotated() -> Self {
        var next = self
        next.rotate()
        return next
    }
}

extension Metris.Mino {
    func collides(in field: Metris.Field) -> Bool {
        return pieces.contains(where: { piece in
            field.collides(at: position(of: piece))
        })
    }

    func place(in field: inout Metris.Field) -> Bool {
        guard !collides(in: field) else { return false }

        pieces.forEach { piece in
            field.placePiece(piece, at: position(of: piece))
        }
        return true
    }

    func clear(in field: inout Metris.Field) {
        pieces.forEach { piece in
            field.placePiece(nil, at: position(of: piece))
        }
    }
}

extension Metris.Mino {
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

extension Metris.Mino {
    static func generate(
        in shape: Shape,
        as descriptor: Metris.Piece.Descriptor,
        at position: Metris.Position = .init(0, 0)
    ) -> Self {
        switch shape {
        case .i:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(-1, 0)),
                    .init(as: descriptor, at: .init(0, 0)),
                    .init(as: descriptor, at: .init(1, 0)),
                    .init(as: descriptor, at: .init(2, 0)),
                ]
            )
        case .j:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(0, 2)),
                    .init(as: descriptor, at: .init(0, 1)),
                    .init(as: descriptor, at: .init(0, 0)),
                    .init(as: descriptor, at: .init(-1, 0)),
                ]
            )
        case .l:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(0, 2)),
                    .init(as: descriptor, at: .init(0, 1)),
                    .init(as: descriptor, at: .init(0, 0)),
                    .init(as: descriptor, at: .init(1, 0)),
                ]
            )
        case .o:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(0, 1)),
                    .init(as: descriptor, at: .init(1, 1)),
                    .init(as: descriptor, at: .init(0, 0)),
                    .init(as: descriptor, at: .init(1, 0)),
                ]
            )
        case .s:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(1, 1)),
                    .init(as: descriptor, at: .init(0, 1)),
                    .init(as: descriptor, at: .init(0, 0)),
                    .init(as: descriptor, at: .init(-1, 0)),
                ]
            )
        case .t:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(-1, 1)),
                    .init(as: descriptor, at: .init(0, 1)),
                    .init(as: descriptor, at: .init(1, 1)),
                    .init(as: descriptor, at: .init(0, 0)),
                ]
            )
        case .z:
            return .init(
                position: position,
                pieces: [
                    .init(as: descriptor, at: .init(-1, 1)),
                    .init(as: descriptor, at: .init(0, 1)),
                    .init(as: descriptor, at: .init(0, 0)),
                    .init(as: descriptor, at: .init(1, 0)),
                ]
            )
        }
    }
}
