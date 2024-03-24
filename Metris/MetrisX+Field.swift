// tomocy

import Metal
import MetalKit

extension MetrisX {
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

extension MetrisX.Field {
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

    func at(_ position: SIMD2<Int>) -> MetrisX.Piece? {
        guard let i = index(at: position) else { return nil }
        return seats[i]
    }

    func at(x: Int, y: Int) -> MetrisX.Piece? {
        return at(.init(x, y))
    }
}

extension MetrisX.Field {
    var pieces: [MetrisX.Piece] { seats.compactMap { $0 } }

    mutating func placePiece(_ piece: MetrisX.Piece?, at position: SIMD2<Int>) {
        guard let i = index(at: position) else { return }
        seats[i] = Engine.Functional.init(piece).state({ piece in
            piece?.place(at: position)
        }).generate()
    }
}

extension MetrisX.Field {
    func collides(with mino: MetrisX.Mino) -> Bool {
        return mino.pieces.contains(where: { piece in
            collides(at: mino.position(of: piece))
        })
    }

    mutating func placeMino(_ mino: MetrisX.Mino) -> Bool {
        guard !collides(with: mino) else { return false }

        mino.pieces.forEach { piece in
            placePiece(piece, at: mino.position(of: piece))
        }

        return true
    }

    mutating func clearMino(_ mino: MetrisX.Mino) {
        mino.pieces.forEach { piece in
            placePiece(nil, at: mino.position(of: piece))
        }
    }
}

extension MetrisX.Field {
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

extension MetrisX.Field {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        pieces.forEach { $0.encode(with: encoder) }
    }
}
