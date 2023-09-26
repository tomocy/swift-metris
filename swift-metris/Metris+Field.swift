// tomocy

import Foundation

extension Metris {
    struct Field {
        init(width: UInt, height: UInt) {
            self.width = width
            self.height = height

            raw = .init(repeating: false, count: Int(width * height))
        }

        func index(x: UInt, y: UInt) -> Int {
            Int(y * width + x)
        }

        func at(x: UInt, y: UInt) -> Bool {
            raw[index(x: x, y: y)]
        }

        mutating func put(x: UInt, y: UInt, _ v: Bool) {
            raw[index(x: x, y: y)] = v
        }

        func append(to primitive: inout IndexedPrimitive) {
            for y in 0..<height {
                for x in 0..<width {
                    if (!at(x: x, y: y)) {
                        continue
                    }

                    var rect = Rectangle(
                        size: CGSize(width: 94, height: 94)
                    )

                    rect.transform.translate.x = Float(100 * x) + 50
                    rect.transform.translate.y = Float(100 * y) + 50

                    rect.append(to: &primitive)
                }
            }
        }

        let width: UInt
        let height: UInt
        private var raw: [Bool] = []
    }
}
