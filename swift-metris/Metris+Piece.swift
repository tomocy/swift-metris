// tomocy

import CoreGraphics

extension Metris {
    struct Piece {
        init(color: CGColor = .black(), position: Field.Point = Field.Point(0, 0)) {
            body = Rectangle(
                size: CGSize(width: 94, height: 94),
                color: color,
                transform: Transform2D()
            )

            self.position = position
        }

        mutating func place(at position: Field.Point) {
            self.position = position
        }

        func placed(at position: Field.Point) -> Self {
            var x = self
            x.place(at: position)
            return x
        }

        func append(to primitive: inout IndexedPrimitive) {
            var body = body
            body.transform.translate(with: SIMD2(Float(100 * position.x) + 50, Float(100 * position.y) + 50))

            body.append(to: &primitive)
        }

        var body: Rectangle
        var position: Field.Point = Field.Point(0, 0)
    }
}
