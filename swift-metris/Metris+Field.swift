// tomocy

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size
            pieces = .init(repeating: nil, count: Int(size.x * size.y))
        }

        let size: SIMD2<UInt>
        private var pieces: [Piece?] = []
    }
}

extension Metris.Field {
    var positionRange: Vector2D<ClosedRange<Int>> {
        positionRange(for: Vector2D(x: 0...0, y: 0...0))
    }

    func positionRange(for boundary: Vector2D<ClosedRange<Int>>) -> Vector2D<ClosedRange<Int>> {
        assert(boundary.x.lowerBound <= 0 && boundary.x.upperBound >= 0)
        assert(boundary.y.lowerBound <= 0 && boundary.y.upperBound >= 0)

        var x: ClosedRange<Int>
        do {
            let lower = 0 + abs(boundary.x.lowerBound)
            let upper = Int(size.x) - 1 - boundary.x.upperBound
            x = lower...upper
        }

        var y: ClosedRange<Int>
        do {
            let lower = 0 + abs(boundary.y.lowerBound)
            let upper = Int(size.y) - 1 - boundary.y.upperBound
            y = lower...upper
        }

        return Vector2D(x: x, y: y)
    }

    func contains(position: SIMD2<Int>) -> Bool {
        positionRange.x.contains(position.x) && positionRange.y.contains(position.y)
    }

    func index(at position: SIMD2<Int>) -> Int? {
        contains(position: position)
            ? Int(position.y * Int(size.x) + position.x)
            : nil
    }

    func index(x: Int, y: Int) -> Int? {
        index(at: SIMD2(x, y))
    }

    func at(_ position: SIMD2<Int>) -> Metris.Piece? {
        guard let i = index(at: position) else { return nil }
        return pieces[i]
    }

    func at(x: Int, y: Int) -> Metris.Piece? {
        at(SIMD2(x, y))
    }

}

extension Metris.Field {
    func collides(_ piece: Metris.Piece?, at position: SIMD2<Int>) -> Bool {
        !contains(position: position) || at(position) != nil
    }

    mutating func place(_ piece: Metris.Piece?, at position: SIMD2<Int>) {
        guard let i = index(at: position) else { return }
        pieces[i] = piece?.placed(at: position)
    }

    mutating func clear(mino: Metris.Mino) {
        mino.clear(on: &self)
    }

    func cleared(mino: Metris.Mino) -> Self {
        var x = self
        x.clear(mino: mino)
        return x
    }

    mutating func clearLines() {
        let range = positionRange

        var bottom = range.y.lowerBound
        for y in range.y {
            if isFilled(in: y) {
                clear(in: y)
                continue
            }

            if y != bottom {
                range.x.forEach { x in
                    let piece = at(x: x, y: y)
                    place(piece, at: SIMD2(x, bottom))
                }
            }
            bottom += 1
        }
    }

    mutating func clear(in line: Int) {
        let range = positionRange
        if !range.y.contains(line) {
            return
        }

        range.x.forEach { x in
            place(nil, at: SIMD2(x, line))
        }
    }

    func isFilled(in line: Int) -> Bool {
        let range = positionRange
        return range.y.contains(line) && range.x.allSatisfy { x in
            at(x: x, y: line) != nil
        }
    }
}

extension Metris.Field: IndexedPrimitiveAppendable {
    func append(to primitive: inout IndexedPrimitive) {
        pieces.compactMap({ $0 }).forEach { $0.append(to: &primitive) }
    }
}
