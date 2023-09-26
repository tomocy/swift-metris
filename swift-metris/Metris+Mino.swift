// tomocy

extension Metris {
    struct Mino {
        enum Shape {
            case i
        }

        static func generate(_ shape: Shape) -> Self {
            switch shape {
            case .i:
                return Self(
                    pieces: [
                        Piece(position: Field.Point(0, 0)),
                        Piece(position: Field.Point(1, 0)),
                        Piece(position: Field.Point(2, 0)),
                        Piece(position: Field.Point(3, 0)),
                    ]
                )
            }
        }

        func place(on field: inout Field, at position: Field.Point) {
            pieces.forEach { piece in
                field.place(piece, at: position &+ piece.position)
            }
        }

        var pieces: [Piece] = []
    }
}
