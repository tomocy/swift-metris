// tomocy

import CoreGraphics

extension Metris {
    struct Mino {
        enum Shape { case i }

        static func generate(_ shape: Shape, descriptor: Piece.Descriptor, at position: SIMD2<Int> = SIMD2(0, 0)) -> Self {
            switch shape {
            case .i:
                return Self(
                    pieces: [
                        Piece(descriptor).placed(at: SIMD2(-1, 0)),
                        Piece(descriptor).placed(at: SIMD2(0, 0)),
                        Piece(descriptor).placed(at: SIMD2(1, 0)),
                        Piece(descriptor).placed(at: SIMD2(2, 0)),
                    ],
                    position: position
                )
            }
        }

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
                pieces[i].position = SIMD2(
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
            pieces.contains(where: { piece in
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
            let (min, max) = pieces.reduce((
                min: SIMD2(0, 0),
                max: SIMD2(0, 0)
            )) { current, piece in
                return (
                    current.min.min(piece.position),
                    current.max.max(piece.position)
                )
            }

            let size = SIMD2(max.x - min.x + 1, max.y - min.y + 1)
            assert(size.x >= 0 && size.y >= 0)

            return SIMD2(size)
        }

        private var pieces: [Piece]

        var position: SIMD2<Int> = SIMD2(0, 0)
    }
}
