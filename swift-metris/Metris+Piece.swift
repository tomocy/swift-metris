// tomocy

import CoreGraphics

extension Metris {
    struct Piece {
        init(as descriptor: Descriptor, at position: Translate = .init(0, 0)) {
            self.position = position

            body = .init(
                size: descriptor.size,
                color: descriptor.color,
                transform: .init().scaled(
                    with: .init(0.94, 0.94)
                )
            )
        }

        var position: Translate = .init(0, 0)
        private var body: Rectangle
    }
}

extension Metris.Piece {
    mutating func place(at position: Metris.Translate) {
        self.position = position
    }

    func placed(at position: Metris.Translate) -> Self {
        var x = self
        x.place(at: position)
        return x
    }
}

extension Metris.Piece: IndexedPrimitiveAppendable {
    func append(to primitive: inout IndexedPrimitive) {
        var target = body

        target.transform.translate(
            with: .init(
                Float(target.size.width) * Float(position.x) + Float(target.size.width) / 2,
                Float(target.size.height) * Float(position.y) + Float(target.size.height) / 2
            )
        )

        target.append(to: &primitive)
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
