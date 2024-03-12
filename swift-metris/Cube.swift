// tomocy

import CoreGraphics
import Metal

struct Cube {
    var size: CGVolume = .init(width: 0, height: 0, depth: 0)
    var color: CGColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    var transform: Transform = .init()
}

extension Cube {
    typealias Transform = D3.Transform<Float>
}

extension Cube {
    func append(to primitive: inout IndexedPrimitive<D3.Vertex<Float, Vertex.Materials.Color>>) {
        typealias Material = Vertex.Materials.Color
        typealias Primitive = IndexedPrimitive<D3.Vertex<Float, Vertex.Materials.Color>>

        let vertices = arrangeVertices(
            for: .init(size)
        ).map({
            $0.materialized(
                with: Vertex.Materials.Color.init(color)
            )
        }).map({
            $0.transformed(with: transform)
        })

        let indices = arrangeIndices(from: primitive.nextStartIndex)

        primitive.append(
            vertices: vertices,
            indices: indices
        )
    }

    func append(to primitive: inout IndexedPrimitive<D3.Vertex<Float, Vertex.Materials.Texture>>) {
        typealias Material = Vertex.Materials.Texture
        typealias Primitive = IndexedPrimitive<D3.Vertex<Float, Material>>

        var vertices: [Primitive.Vertex] = arrangeVertices(for: .init(size))
        do {
            vertices[0].materialize(
                with: Material.init(coordinate: .init(0, 0))
            )
            vertices[1].materialize(
                with: Material.init(coordinate: .init(1, 0))
            )
            vertices[2].materialize(
                with: Material.init(coordinate: .init(1, 1))
            )
            vertices[3].materialize(
                with: Material.init(coordinate: .init(0, 1))
            )

            vertices[4].materialize(
                with: Material.init(coordinate: .init(0, 0))
            )
            vertices[5].materialize(
                with: Material.init(coordinate: .init(1, 0))
            )
            vertices[6].materialize(
                with: Material.init(coordinate: .init(1, 1))
            )
            vertices[7].materialize(
                with: Material.init(coordinate: .init(0, 1))
            )

            vertices = vertices.map({
                $0.transformed(with: transform)
            })
        }

        let indices = arrangeIndices(from: primitive.nextStartIndex)

        primitive.append(
            vertices: vertices,
            indices: indices
        )
    }

    private func arrangeVertices<M: Vertex.Material>(
        for size: D3.Vertex<Float, M>.Measure
    ) -> [D3.Vertex<Float, M>] {
        let halfSize = D3.Vertex<Float, M>.Measure.init(size) / 2

        return [
            // front
            // 0
            .init(
                position: .init(-halfSize.x, halfSize.y, -halfSize.z)
            ),
            // 1
            .init(
                position: .init(halfSize.x, halfSize.y, -halfSize.z)
            ),
            // 2
            .init(
                position: .init(halfSize.x, -halfSize.y, -halfSize.z)
            ),
            // 3
            .init(
                position: .init(-halfSize.x, -halfSize.y, -halfSize.z)
            ),

            // back
            // 4
            .init(
                position: .init(halfSize.x, halfSize.y, halfSize.z)
            ),
            // 5
            .init(
                position: .init(-halfSize.x, halfSize.y, halfSize.z)
            ),
            // 6
            .init(
                position: .init(-halfSize.x, -halfSize.y, halfSize.z)
            ),
            // 7
            .init(
                position: .init(halfSize.x, -halfSize.y, halfSize.z)
            ),
        ]
    }

    private func arrangeIndices(from start: IndexedPrimitive.Index) -> [IndexedPrimitive.Index] {
        return [
            // front
            start, start + 1, start + 2,
            start + 2, start + 3, start,
            // back
            start + 4, start + 5, start + 6,
            start + 6, start + 7, start + 4,
            // left
            start + 1, start + 4, start + 7,
            start + 7, start + 2, start + 1,
            // right
            start + 5, start, start + 3,
            start + 3, start + 6, start + 5,
            // top
            start + 1, start, start + 5,
            start + 5, start + 4, start + 1,
            // bottom
            start + 7, start + 6, start + 3,
            start + 3, start + 2, start + 7,
        ]
    }
}
