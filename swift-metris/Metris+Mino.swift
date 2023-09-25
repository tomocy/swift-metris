// tomocy

extension Metris {
    struct Mino {
        func put(on field: inout Metris.Field, at position: SIMD2<UInt>) {
            for piece in pieces {
                field.set(
                    x: position.x + piece.x,
                    y: position.y + piece.y,
                    true
                )
            }
        }

        var pieces: [SIMD2<UInt>] = []
    }
}
