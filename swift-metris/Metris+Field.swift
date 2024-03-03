// tomocy

import Metal

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size
            pieces = .init(
                repeating: nil,
                count: .init(size.x * size.y)
            )
        }

        let size: SIMD2<UInt>
        private var pieces: [Piece?] = []

        private var frameBuffers: FrameBuffers = .init()
    }
}

extension Metris.Field {
    var positionRange: Vector2D<ClosedRange<Int>> {
        positionRange(
            for: .init(
                x: 0...0,
                y: 0...0
            )
        )
    }

    func positionRange(for boundary: Vector2D<ClosedRange<Int>>) -> Vector2D<ClosedRange<Int>> {
        assert(boundary.x.lowerBound <= 0 && boundary.x.upperBound >= 0)
        assert(boundary.y.lowerBound <= 0 && boundary.y.upperBound >= 0)

        var x: ClosedRange<Int>
        do {
            let lower = 0 + abs(boundary.x.lowerBound)
            let upper = .init(size.x) - 1 - boundary.x.upperBound
            x = lower...upper
        }

        var y: ClosedRange<Int>
        do {
            let lower = 0 + abs(boundary.y.lowerBound)
            let upper = .init(size.y) - 1 - boundary.y.upperBound
            y = lower...upper
        }

        return .init(x: x, y: y)
    }

    func contains(position: Metris.Translate) -> Bool {
        return positionRange.x.contains(position.x)
            && positionRange.y.contains(position.y)
    }

    func index(at position: Metris.Translate) -> Int? {
        return contains(position: position)
                ? Int(position.y * Int(size.x) + position.x)
                : nil
    }

    func index(x: Int, y: Int) -> Int? {
        return index(at: .init(x, y))
    }

    func at(_ position: Metris.Translate) -> Metris.Piece? {
        guard let i = index(at: position) else { return nil }
        return pieces[i]
    }

    func at(x: Int, y: Int) -> Metris.Piece? {
        return at(.init(x, y))
    }

}

extension Metris.Field {
    func collides(_ piece: Metris.Piece?, at position: Metris.Translate) -> Bool {
        return !contains(position: position)
            || at(position) != nil
    }

    mutating func place(_ piece: Metris.Piece?, at position: Metris.Translate) {
        guard let i = index(at: position) else { return }
        pieces[i] = piece?.placed(at: position)
    }

    mutating func clearMino(_ mino: Metris.Mino) {
        mino.clear(on: &self)
    }

    mutating func clearLines() {
        let range = positionRange

        var bottom = range.y.lowerBound
        for y in range.y {
            if hasLineFilled(at: y) {
                clearLine(at: y)
                continue
            }

            if y != bottom {
                range.x.forEach { x in
                    let piece = at(x: x, y: y)
                    place(piece, at: .init(x, bottom))
                }
            }
            bottom += 1
        }
    }

    mutating func clearLine(at index: Int) {
        let range = positionRange
        if !range.y.contains(index) {
            return
        }

        range.x.forEach { x in
            place(nil, at: .init(x, index))
        }
    }

    func hasLineFilled(at index: Int) -> Bool {
        let range = positionRange
        return range.y.contains(index) && range.x.allSatisfy { x in
            at(x: x, y: index) != nil
        }
    }
}

extension Metris.Field: IndexedPrimitiveAppendable {
    func append(to primitive: inout IndexedPrimitive) {
        pieces.compactMap({ $0 }).forEach {
            $0.append(to: &primitive)
        }
    }
}

extension Metris.Field: MTLFrameRenderCommandEncodableAt {
    private struct FrameBuffers {
        var data: MTLSizedBuffers = .init(options: .storageModeShared)
        var index: MTLSizedBuffers = .init(options: .storageModeShared)
    }

    mutating func encode(with encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame) {
        var primitive = IndexedPrimitive()
        append(to: &primitive)

        primitive.encode(
            with: encoder,
            to: .init(
                data: frameBuffers.data.take(
                    at: frame.id,
                    of: primitive.verticesSize,
                    with: encoder.device
                ),
                index: frameBuffers.index.take(
                    at: frame.id,
                    of: primitive.indicesSize,
                    with: encoder.device
                )
            ),
            at: index
        )
    }
}
