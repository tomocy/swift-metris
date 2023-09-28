// tomocy

import CoreGraphics

extension Metris {
    struct Piece {
        init(_ descriptor: Descriptor, position: Field.Point = Field.Point(0, 0)) {
            body = Rectangle(
                size: descriptor.size,
                color: descriptor.color,
                transform: Transform2D().scaled(with: SIMD2(0.94, 0.94))
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
            var target = body

            target.transform.translate(
                with: SIMD2(
                    Float(target.size.width) * Float(position.x) + Float(target.size.width) / 2,
                    Float(target.size.height) * Float(position.y) + Float(target.size.height) / 2
                )
            )

            target.append(to: &primitive)
        }

        private var body: Rectangle
        var position: Field.Point = Field.Point(0, 0)
    }
}

extension Metris.Piece {
    struct Descriptor {
        func resized(with size: CGSize) -> Self {
            var x = self
            x.size = size
            return x
        }

        func colorized(with color: CGColor) -> Self {
            var x = self
            x.color = color
            return x
        }

        var size: CGSize
        var color: CGColor
    }
}
