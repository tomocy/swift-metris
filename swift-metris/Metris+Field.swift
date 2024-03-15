// tomocy

import Metal
import MetalKit

extension Metris {
    struct Field {
        init(for size: SIMD2<UInt>) {
            self.size = size
            seats = .init(
                repeating: nil,
                count: .init(size.x * size.y)
            )
        }

        let size: SIMD2<UInt>
        private var seats: [Piece?] = []

        private var frameBuffers: Indexed<MTLSizedBuffers> = .init(
            data: .init(options: .storageModeShared),
            index: .init(options: .storageModeShared)
        )
    }
}

extension Metris.Field {
    var positionRange: Vector2D<ClosedRange<Int>> {
        return positionRange(
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

    func contains(_ position: Metris.Position) -> Bool {
        return positionRange.x.contains(position.x)
            && positionRange.y.contains(position.y)
    }

    func collides(at position: Metris.Position) -> Bool {
        return !contains(position)
            || at(position) != nil
    }

    func index(at position: Metris.Position) -> Int? {
        return contains(position)
                ? Int(position.y * Int(size.x) + position.x)
                : nil
    }

    func index(x: Int, y: Int) -> Int? {
        return index(at: .init(x, y))
    }

    func at(_ position: Metris.Position) -> Metris.Piece? {
        guard let i = index(at: position) else { return nil }
        return seats[i]
    }

    func at(x: Int, y: Int) -> Metris.Piece? {
        return at(.init(x, y))
    }
}

extension Metris.Field {
    var pieces: [Metris.Piece] { seats.compactMap { $0 } }

    mutating func placePiece(_ piece: Metris.Piece?, at position: Metris.Position) {
        guard let i = index(at: position) else { return }
        seats[i] = piece?.placed(at: position)
    }
}

extension Metris.Field {
    func collides(with mino: Metris.Mino) -> Bool {
        return mino.pieces.contains(where: { piece in
            collides(at: mino.position(of: piece))
        })
    }

    mutating func placeMino(_ mino: Metris.Mino) -> Bool {
        guard !collides(with: mino) else { return false }

        mino.pieces.forEach { piece in
            placePiece(piece, at: mino.position(of: piece))
        }

        return true
    }

    mutating func clearMino(_ mino: Metris.Mino) {
        mino.pieces.forEach { piece in
            placePiece(nil, at: mino.position(of: piece))
        }
    }
}

extension Metris.Field {
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
                    placePiece(piece, at: .init(x, bottom))
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
            placePiece(nil, at: .init(x, index))
        }
    }

    func hasLineFilled(at index: Int) -> Bool {
        let range = positionRange
        return range.y.contains(index) && range.x.allSatisfy { x in
            at(x: x, y: index) != nil
        }
    }
}

extension Metris.Field: IndexedPrimitive.Projectable, IndexedPrimitive.Appendable {
    typealias Vertex = D3.Vertex<Float>

    func project(beside primitive: IndexedPrimitive<Vertex>) -> IndexedPrimitive<Vertex> {
        var primitive = primitive
        append(to: &primitive)
        return primitive
    }

    func append(to primitive: inout IndexedPrimitive<Vertex>) {
        pieces.forEach { piece in
            piece.append(to: &primitive)
        }
    }
}

extension Metris.Field: MTLFrameRenderCommandEncodableAt {
    mutating func encode(
        with encoder: MTLRenderCommandEncoder,
        at index: Int,
        in frame: MTLRenderFrame
    ) {
        let primitive = project()
        let buffers = Indexed.init(
            data: frameBuffers.data.take(
                at: frame.id,
                of: primitive.vertices.size,
                with: encoder.device
            ),
            index: frameBuffers.index.take(
                at: frame.id,
                of: primitive.indices.size,
                with: encoder.device
            )
        )

        do {
            primitive.vertices.write(to: buffers.data.contents())
            encoder.setVertexBuffer(buffers.data, offset: 0, index: index)
        }

        primitive.indices.write(to: buffers.index.contents())

        pieces.map({ $0.project() }).enumerated().forEach { i, piece in
            encoder.setFragmentTexture(
                pieces[i].body.material.diffuse,
                index: 0
            )

            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: piece.indices.count,
                indexType: .uint16,
                indexBuffer: buffers.index,
                indexBufferOffset: piece.indices.size * i
            )
        }
    }
}
