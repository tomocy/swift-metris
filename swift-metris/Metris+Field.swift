// tomocy

import Foundation

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size
            pieces = .init(repeating: nil, count: Int(size.x * size.y))
        }

        func index(at position: SIMD2<Int>) -> Int {
            index(x: position.x, y: position.y)
        }

        func index(x: Int, y: Int) -> Int {
            Int(y * Int(size.x) + x)
        }

        func at(_ position: SIMD2<Int>) -> Piece? {
            at(x: position.x, y: position.y)
        }

        func at(x: Int, y: Int) -> Piece? {
            let i = index(x: x, y: y)
            return pieces[i]
        }

        func positionRange(for size: SIMD2<UInt>) -> Vector2D<ClosedRange<Int>> {
            return Vector2D(
                x: 0...Int(self.size.x - size.x),
                y: 0...Int(self.size.y - size.y)
            )
        }

        mutating func place(_ piece: Piece?, at position: SIMD2<Int>) {
            let i = index(at: position)
            pieces[i] = piece?.placed(at: position)
        }

        func append(to primitive: inout IndexedPrimitive) {
            pieces.compactMap({ $0 }).forEach { $0.append(to: &primitive) }
        }

        let size: SIMD2<UInt>
        private var pieces: [Piece?] = []
    }
}
