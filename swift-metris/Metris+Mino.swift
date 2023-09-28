// tomocy

import CoreGraphics

extension Metris {
    struct Mino {
        enum Shape { case i }

        static func generate(_ shape: Shape, descriptor: Piece.Descriptor) -> Self {
            switch shape {
            case .i:
                return Self(
                    size: SIMD2(4, 1),
                    pieces: [
                        Piece(descriptor).placed(at: SIMD2(0, 0)),
                        Piece(descriptor).placed(at: SIMD2(1, 0)),
                        Piece(descriptor).placed(at: SIMD2(2, 0)),
                        Piece(descriptor).placed(at: SIMD2(3, 0)),
                    ]
                )
            }
        }

        func place(on field: inout Field, at position: SIMD2<UInt>) {
            pieces.forEach { piece in
                field.place(piece, at: position &+ piece.position)
            }
        }

        let size: SIMD2<UInt>
        private var pieces: [Piece] = []
    }
}
