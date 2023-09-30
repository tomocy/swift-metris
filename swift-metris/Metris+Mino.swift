// tomocy

import CoreGraphics

extension Metris {
    struct Mino {
        enum Shape { case i }

        static func generate(_ shape: Shape, descriptor: Piece.Descriptor, at position: SIMD2<UInt> = SIMD2(0, 0)) -> Self {
            switch shape {
            case .i:
                return Self(
                    size: SIMD2(4, 1),
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

        func position(of piece: Piece) -> SIMD2<UInt> { position &+ piece.position }

        func collides(on field: Field) -> Bool {
            !pieces.allSatisfy { piece in
                field.at(position(of: piece)) == nil
            }
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

        let size: SIMD2<UInt>
        private var pieces: [Piece]

        var position: SIMD2<UInt> = SIMD2(0, 0)
    }
}
