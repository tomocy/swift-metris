// tomocy

import CoreGraphics

extension Metris {
    struct Mino {
        enum Shape { case i }

        static func generate(_ shape: Shape, descriptor: Piece.Descriptor) -> Self {
            switch shape {
            case .i:
                return Self(
                    width: 4,
                    height: 1,
                    pieces: [
                        Piece(descriptor).placed(at: Field.Point(0, 0)),
                        Piece(descriptor).placed(at: Field.Point(1, 0)),
                        Piece(descriptor).placed(at: Field.Point(2, 0)),
                        Piece(descriptor).placed(at: Field.Point(3, 0)),
                    ]
                )
            }
        }

        func place(on field: inout Field, at position: Field.Point) {
            pieces.forEach { piece in
                field.place(piece, at: position &+ piece.position)
            }
        }

        let width: UInt
        let height: UInt
        private var pieces: [Piece] = []
    }
}
