// tomocy

import CoreGraphics

extension Metris {
    struct Piece {
        init(as descriptor: Descriptor, at position: Position = .init(0, 0)) {
            self.position = position

            body = .init(
                size: descriptor.size,
                color: descriptor.color,
                transform: .init().scaled(
                    with: .init(0.94, 0.94)
                )
            )
        }

        var position: Position = .init(0, 0)
        private var body: Rectangle
    }
}

extension Metris.Piece {
    mutating func place(at position: Metris.Position) {
        self.position = position
    }

    func placed(at position: Metris.Position) -> Self {
        var next = self
        next.place(at: position)
        return next
    }
}

extension Metris.Piece: IndexedPrimitive2DAppendable {
    func append(to primitive: inout IndexedPrimitive2D) {
        var body = self.body

        body.transform.translate(
            with: .init(
                Float(body.size.width) * Float(position.x) + Float(body.size.width) / 2,
                Float(body.size.height) * Float(position.y) + Float(body.size.height) / 2
            )
        )

        body.append(to: &primitive)
    }
}

extension Metris.Piece: IndexedPrimitive3DAppendable {
    func append(to primitive: inout IndexedPrimitive3D) {
        var body = self.body

        body.transform.translate(
            with: .init(
                Float(body.size.width) * Float(position.x) + Float(body.size.width) / 2,
                Float(body.size.height) * Float(position.y) + Float(body.size.height) / 2,
                0
            )
        )

        body.append(to: &primitive)
    }
}

extension Metris.Piece {
    struct Descriptor {
        var size: CGSize
        var color: CGColor
    }
}

extension Metris.Piece.Descriptor {
    func resized(with size: CGSize) -> Self {
        var next = self
        next.size = size
        return next
    }

    func colorized(with color: CGColor) -> Self {
        var next = self
        next.color = color
        return next
    }
}
