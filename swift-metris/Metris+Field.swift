// tomocy

import Metal

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size
            pieces = .init(repeating: nil, count: Int(size.x * size.y))
        }

        let size: SIMD2<UInt>
        private var pieces: [Piece?] = []

        private var frameDataBuffers: [Int: MTLBuffer] = [:]
        private var frameIndexBuffers: [Int: MTLBuffer] = [:]
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

    mutating func clearMino(_ mino: Metris.Mino) {
        mino.clear(on: &self)
    }

    mutating func clearLines() {
        let range = positionRange

        var bottom = range.y.lowerBound
        for y in range.y {
            if isLineFilled(at: y) {
                clearLine(at: y)
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

    mutating func clearLine(at index: Int) {
        let range = positionRange
        if !range.y.contains(index) {
            return
        }

        range.x.forEach { x in
            place(nil, at: SIMD2(x, index))
        }
    }

    func isLineFilled(at index: Int) -> Bool {
        let range = positionRange
        return range.y.contains(index) && range.x.allSatisfy { x in
            at(x: x, y: index) != nil
        }
    }
}

extension Metris.Field: IndexedPrimitiveAppendable {
    func append(to primitive: inout IndexedPrimitive) {
        pieces.compactMap({ $0 }).forEach { $0.append(to: &primitive) }
    }
}

extension Metris.Field: MTLFrameRenderCommandEncodableAt {
    mutating func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame) {
        var primitive = IndexedPrimitive()
        append(to: &primitive)

        do {
            let hasBuffer = frameDataBuffers.contains(where: { (id, buffer) in
                return id == frame.id
                    && buffer.length == primitive.verticesSize
            })
            if !hasBuffer {
                frameDataBuffers[frame.id] = encoder.device.makeBuffer(
                    length: primitive.verticesSize,
                    options: .storageModeShared
                )
            }
        }

        do {
            let hasBuffer = frameIndexBuffers.contains(where: { (id, buffer) in
                return id == frame.id
                    && buffer.length == primitive.indicesSize
            })
            if !hasBuffer {
                frameIndexBuffers[frame.id] = encoder.device.makeBuffer(
                    length: primitive.indicesSize,
                    options: .storageModeShared
                )
            }
        }

        primitive.encode(
            to: encoder,
            with: .init(
                data: frameDataBuffers[frame.id]!,
                index: frameIndexBuffers[frame.id]!
            ),
            at: index
        )
    }
}
