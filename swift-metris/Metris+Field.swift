// tomocy

import Foundation

extension Metris {
    struct Field {
        init(size: SIMD2<UInt>) {
            self.size = size
            pieces = .init(repeating: nil, count: Int(size.x * size.y))
        }

        func index(at position: SIMD2<UInt>) -> Int {
            index(x: position.x, y: position.y)
        }

        func index(x: UInt, y: UInt) -> Int {
            Int(y * size.x + x)
        }

        func at(_ position: SIMD2<UInt>) -> Piece? {
            at(x: position.x, y: position.y)
        }

        func at(x: UInt, y: UInt) -> Piece? {
            let i = index(x: x, y: y)
            return pieces[i]
        }

        mutating func place(_ piece: Piece?, at position: SIMD2<UInt>) {
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
