// tomocy

import Foundation

extension Metris {
    struct Field {
        typealias Point = SIMD2<UInt>

        init(width: UInt, height: UInt) {
            self.width = width
            self.height = height

            pieces = .init(repeating: nil, count: Int(width * height))
        }

        func index(at position: Point) -> Int {
            index(x: position.x, y: position.y)
        }

        func index(x: UInt, y: UInt) -> Int {
            Int(y * width + x)
        }

        func at(_ position: Point) -> Piece? {
            at(x: position.x, y: position.y)
        }

        func at(x: UInt, y: UInt) -> Piece? {
            let i = index(x: x, y: y)
            return pieces[i]
        }

        mutating func place(_ piece: Piece?, at position: Field.Point) {
            let i = index(at: position)
            pieces[i] = piece?.placed(at: position)
        }

        func append(to primitive: inout IndexedPrimitive) {
            pieces.compactMap({ $0 }).forEach { $0.append(to: &primitive) }
        }

        let width: UInt
        let height: UInt
        private var pieces: [Piece?] = []
    }
}
