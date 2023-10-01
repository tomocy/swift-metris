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
                        Piece(descriptor).placed(at: SIMD2(0, 0)),
                        Piece(descriptor).placed(at: SIMD2(1, 0)),
                        Piece(descriptor).placed(at: SIMD2(2, 0)),
                        Piece(descriptor).placed(at: SIMD2(3, 0)),
                    ],
                    position: position
                )
            }
        }

        func position(of piece: Piece) -> SIMD2<Int> { position &+ piece.position }

        func collides(on field: Field) -> Bool {
            pieces.contains(where: { piece in
                field.collides(piece, at: position(of: piece))
            })
        }

        func place(on field: inout Field) {
            if collides(on: field) {
                return
            }

            pieces.forEach { piece in
                field.place(piece, at: position(of: piece))
            }
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
