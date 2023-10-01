// tomocy

import Foundation

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size
            pieces = .init(repeating: nil, count: Int(size.x * size.y))
        }

        var positionRange: Vector2D<ClosedRange<Int>> {
            positionRange(for: SIMD2(1, 1))
        }

        func positionRange(for size: SIMD2<UInt>) -> Vector2D<ClosedRange<Int>> {
            return Vector2D(
                x: 0...Int(self.size.x - size.x),
                y: 0...Int(self.size.y - size.y)
            )
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

        func at(_ position: SIMD2<Int>) -> Piece? {
            guard let i = index(at: position) else { return nil }
            return pieces[i]
        }

        func at(x: Int, y: Int) -> Piece? {
            at(SIMD2(x, y))
        }

        func collides(_ piece: Piece?, at position: SIMD2<Int>) -> Bool {
            !contains(position: position) || at(position) != nil
        }

        mutating func place(_ piece: Piece?, at position: SIMD2<Int>) {
            guard let i = index(at: position) else { return }
            pieces[i] = piece?.placed(at: position)
        }

        mutating func clear(mino: Mino) {
            mino.clear(on: &self)
        }

        func cleared(mino: Mino) -> Self {
            var x = self
            x.clear(mino: mino)
            return x
        }

        func append(to primitive: inout IndexedPrimitive) {
            pieces.compactMap({ $0 }).forEach { $0.append(to: &primitive) }
        }

        let size: SIMD2<UInt>
        private var pieces: [Piece?] = []
    }
}
