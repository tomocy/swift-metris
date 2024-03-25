// tomocy

import Metal
import MetalKit

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size

            seats = .init(
                repeating: nil,
                count: .init(size.x * size.y)
            )
        }

        let size: SIMD2<UInt>
        private var seats: [Piece?] = []
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

    func contains(_ position: SIMD2<Int>) -> Bool {
        return positionRange.x.contains(position.x)
            && positionRange.y.contains(position.y)
    }

    func collides(at position: SIMD2<Int>) -> Bool {
        return !contains(position)
            || at(position) != nil
    }

    func index(at position: SIMD2<Int>) -> Int? {
        return contains(position)
                ? Int(position.y * Int(size.x) + position.x)
                : nil
    }

    func index(x: Int, y: Int) -> Int? {
        return index(at: .init(x, y))
    }

    func at(_ position: SIMD2<Int>) -> Metris.Piece? {
        guard let i = index(at: position) else { return nil }
        return seats[i]
    }

    func at(x: Int, y: Int) -> Metris.Piece? {
        return at(.init(x, y))
    }
}

extension Metris.Field {
    var pieces: [Metris.Piece] { seats.compactMap { $0 } }

    mutating func placePiece(_ piece: Metris.Piece?, at position: SIMD2<Int>) {
        guard let i = index(at: position) else { return }
        seats[i] = Engine.Functional.init(piece).state({ piece in
            piece?.place(at: position)
        }).generate()
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

extension Metris.Field {
    func encode(in context: some Shader.RenderContext) {
        pieces.forEach { $0.encode(in: context) }
    }
}
