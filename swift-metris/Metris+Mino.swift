// tomocy

import CoreGraphics

extension Metris {
    struct Mino {
        mutating func position(at position: SIMD2<Int>) {
            self.position = position
        }

        func positioned(at position: SIMD2<Int>) -> Self {
            var x = self
            x.position(at: position)
            return x
        }

        mutating func position(by delta: SIMD2<Int>) {
            position &+= delta
        }

        func positioned(by delta: SIMD2<Int>) -> Self {
            var x = self
            x.position(by: delta)
            return x
        }

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
            var x = self
            x.rotate()
            return x
        }

        func position(of piece: Piece) -> SIMD2<Int> { position &+ piece.position }

        func collides(on field: Field) -> Bool {
            return pieces.contains(where: { piece in
                field.collides(piece, at: position(of: piece))
            })
        }

        func place(on field: inout Field) -> Bool {
            if collides(on: field) {
                return false
            }

            pieces.forEach { piece in
                field.place(piece, at: position(of: piece))
            }
            return true
        }

        func clear(on field: inout Field) {
            pieces.forEach { piece in
                field.place(nil, at: position(of: piece))
            }
        }

        // O(pieces)
        var size: SIMD2<UInt> {
            let boundary = boundary
            let size = SIMD2.init(
                boundary.x.upperBound - boundary.x.lowerBound + 1,
                boundary.y.upperBound - boundary.y.lowerBound + 1
            )
            assert(size.x >= 0 && size.y >= 0)

            return .init(size)
        }

        // O(pieces)
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

        private var pieces: [Piece]

        var position: SIMD2<Int> = .init(0, 0)
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
    typealias Piece = Metris.Piece

    static func generate(_ shape: Shape, descriptor: Piece.Descriptor, at position: SIMD2<Int> = .init(0, 0)) -> Self {
        switch shape {
        case .i:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(-1, 0)),
                    .init(descriptor).placed(at: .init(0, 0)),
                    .init(descriptor).placed(at: .init(1, 0)),
                    .init(descriptor).placed(at: .init(2, 0)),
                ],
                position: position
            )
        case .j:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(0, 2)),
                    .init(descriptor).placed(at: .init(0, 1)),
                    .init(descriptor).placed(at: .init(0, 0)),
                    .init(descriptor).placed(at: .init(-1, 0)),
                ],
                position: position
            )
        case .l:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(0, 2)),
                    .init(descriptor).placed(at: .init(0, 1)),
                    .init(descriptor).placed(at: .init(0, 0)),
                    .init(descriptor).placed(at: .init(1, 0)),
                ],
                position: position
            )
        case .o:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(0, 1)),
                    .init(descriptor).placed(at: .init(1, 1)),
                    .init(descriptor).placed(at: .init(0, 0)),
                    .init(descriptor).placed(at: .init(1, 0)),
                ]
            )
        case .s:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(1, 1)),
                    .init(descriptor).placed(at: .init(0, 1)),
                    .init(descriptor).placed(at: .init(0, 0)),
                    .init(descriptor).placed(at: .init(-1, 0)),
                ]
            )
        case .t:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(-1, 1)),
                    .init(descriptor).placed(at: .init(0, 1)),
                    .init(descriptor).placed(at: .init(1, 1)),
                    .init(descriptor).placed(at: .init(0, 0)),
                ]
            )
        case .z:
            return Self(
                pieces: [
                    .init(descriptor).placed(at: .init(-1, 1)),
                    .init(descriptor).placed(at: .init(0, 1)),
                    .init(descriptor).placed(at: .init(0, 0)),
                    .init(descriptor).placed(at: .init(1, 0)),
                ]
            )
        }
    }
}
