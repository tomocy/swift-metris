// tomocy

import CoreGraphics
import Metal

struct Cube {
    var size: CGVolume = .init(width: 0, height: 0, depth: 0)
    var material: Material.Source = .init()
    var transform: Transform = .init()
}

extension Cube {
    typealias Transform = D3.Transform<Float>
}

extension Cube {
    mutating func materialize(with material: Material.Source) {
        self.material = material
    }

    func materialized(with material: Material.Source) -> Self {
        return mapState(self) { $0.materialize(with: material) }
    }

    mutating func transform(with transform: Transform) {
        self.transform.transform(by: transform)
    }

    func transformed(with transform: Transform) -> Self {
        return mapState(self) { $0.transform(with: transform) }
    }

    mutating func transform(by transform: Transform) {
        self.transform.transform(by: transform)
    }

    func transformed(by transform: Transform) -> Self {
        return mapState(self) { $0.transform(by: transform) }
    }
}

extension Cube: IndexedPrimitive.Projectable, IndexedPrimitive.Appendable {
    typealias Vertex = D3.Vertex<Float>

    func project(beside primitive: IndexedPrimitive<Vertex>) -> IndexedPrimitive<Vertex> {
        typealias Primitive = IndexedPrimitive<Vertex>
        typealias Index = Primitive.Index
        typealias Material = Primitive.Vertex.Material

        var vertices: [Vertex] = []
        do {
            let halfSize = Vertex.Measure.init(size) / 2

            vertices += [
                // front
                // 0
                .init(
                    position: .init(-halfSize.x, halfSize.y, -halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(0, 0))
                    )
                ),
                // 1
                .init(
                    position: .init(halfSize.x, halfSize.y, -halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(1, 0))
                    )
                ),
                // 2
                .init(
                    position: .init(halfSize.x, -halfSize.y, -halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(1, 1))
                    )
                ),
                // 3
                .init(
                    position: .init(-halfSize.x, -halfSize.y, -halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(0, 1))
                    )
                ),

                // back
                // 4
                .init(
                    position: .init(halfSize.x, halfSize.y, halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(0, 0))
                    )
                ),
                // 5
                .init(
                    position: .init(-halfSize.x, halfSize.y, halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(1, 0))
                    )
                ),
                // 6
                .init(
                    position: .init(-halfSize.x, -halfSize.y, halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(1, 1))
                    )
                ),
                // 7
                .init(
                    position: .init(halfSize.x, -halfSize.y, halfSize.z),
                    material: .init(
                        diffuse: .init(coordinate: .init(0, 1))
                    )
                ),
            ]

            vertices = vertices.map({
                $0.transformed(with: transform)
            })
        }

        var indices: [Index] = []
        do {
            let start = primitive.nextStartIndex
            indices += [
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

        return .init(
            vertices: vertices,
            indices: indices
        )
    }
}