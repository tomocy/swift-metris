// tomocy

import CoreGraphics
import Metal

extension Metris {
    struct Piece {
        init(as descriptor: Descriptor, at position: Position = .init(0, 0)) {
            self.position = position

            body = .init(
                size: descriptor.size,
                material: descriptor.material,
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
        return mapState(self) { $0.place(at: position) }
    }
}

extension Metris.Piece: IndexedPrimitive.Projectable, IndexedPrimitive.Appendable {
    typealias Vertex = D3.Vertex<Float>

    func project(beside primitive: IndexedPrimitive<Vertex>) -> IndexedPrimitive<Vertex> {
        var body = self.body

        // Shift the origin from the center to the bottom left.
        body.transform.translate(
            with: .init(
                Float(body.size.width) * .init(position.x) + .init(body.size.width) / 2,
                Float(body.size.height) * .init(position.y) + .init(body.size.height) / 2,
                0
            )
        )

        return body.project(beside: primitive)
    }
}

extension Metris.Piece {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int> = .zero,
        beside primitive: IndexedPrimitive<Vertex>
    ) {
        body.material?.encode(with: encoder)

        project().encode(
            with: encoder,
            to: buffer, by: offset,
            beside: primitive
        )
    }
}

extension Metris.Piece {
    struct Descriptor {
        var size: CGVolume
        var material: Material.Source?
    }
}

extension Metris.Piece.Descriptor {
    func resized(with size: CGVolume) -> Self {
        return mapState(self) { $0.size = size }
    }

    func materialized(with material: Material.Source) -> Self {
        return mapState(self) { $0.material = material }
    }
}
