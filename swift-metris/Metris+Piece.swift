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
                    with: .init(filled: 0.94)
                )
            )
        }

        var position: Position = .init(0, 0)
        var body: Cube
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

extension Metris.Piece: IndexedPrimitive3DAppendable {
    func append(to primitive: inout IndexedPrimitive3D) {
        var body = self.body

        // Shift the origin from the center to the bottom left.
        body.transform.translate(
            with: .init(
                Float(body.size.width) * .init(position.x) + .init(body.size.width) / 2,
                Float(body.size.height) * .init(position.y) + .init(body.size.height) / 2,
                0
            )
        )

        body.append(to: &primitive)
    }
}

extension Metris.Piece {
    struct Descriptor {
        var size: CGVolume
        var color: CGColor
    }
}

extension Metris.Piece.Descriptor {
    func resized(with size: CGVolume) -> Self {
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
