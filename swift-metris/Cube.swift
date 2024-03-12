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
    func append(to primitive: inout IndexedPrimitive<D3.Vertex<Float>>) {
        typealias Primitive = IndexedPrimitive<D3.Vertex<Float>>

        var vertices: [Primitive.Vertex] = []
        do {
            let halfSize = Primitive.Vertex.Measure.init(size) / 2
            vertices += [
                // front
                /* 0 */ .init(at: .init(-halfSize.x, halfSize.y, -halfSize.z)),
                /* 1 */ .init(at: .init(halfSize.x, halfSize.y, -halfSize.z)),
                /* 2 */ .init(at: .init(halfSize.x, -halfSize.y, -halfSize.z)),
                /* 3 */ .init(at: .init(-halfSize.x, -halfSize.y, -halfSize.z)),
                // back
                /* 4 */ .init(at: .init(halfSize.x, halfSize.y, halfSize.z)),
                /* 5 */ .init(at: .init(-halfSize.x, halfSize.y, halfSize.z)),
                /* 6 */ .init(at: .init(-halfSize.x, -halfSize.y, halfSize.z)),
                /* 7 */ .init(at: .init(halfSize.x, -halfSize.y, halfSize.z)),
            ]

            vertices = vertices.map({
                $0.colorized(with: .init(color))
            }).map({
                $0.transformed(with: transform)
            })
        }

        var indices: [Primitive.Index] = []
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

        primitive.append(
            vertices: vertices,
            indices: indices
        )
    }
}

extension Cube: IndexedPrimitive3DAppendable {
    typealias Precision = Float

    func append(to primitive: inout Primitive) {
        var vertices: [Primitive.Vertex] = []
        do {
            let halfSize = SIMD3<Precision>.init(size) / 2
            vertices += [
                // front
                /* 0 */ .init(at: .init(-halfSize.x, halfSize.y, -halfSize.z)),
                /* 1 */ .init(at: .init(halfSize.x, halfSize.y, -halfSize.z)),
                /* 2 */ .init(at: .init(halfSize.x, -halfSize.y, -halfSize.z)),
                /* 3 */ .init(at: .init(-halfSize.x, -halfSize.y, -halfSize.z)),
                // back
                /* 4 */ .init(at: .init(halfSize.x, halfSize.y, halfSize.z)),
                /* 5 */ .init(at: .init(-halfSize.x, halfSize.y, halfSize.z)),
                /* 6 */ .init(at: .init(-halfSize.x, -halfSize.y, halfSize.z)),
                /* 7 */ .init(at: .init(halfSize.x, -halfSize.y, halfSize.z)),
            ]

            vertices = vertices.map({
                $0.colorized(with: .init(color))
            }).map({
                $0.transformed(with: transform)
            })
        }

        var indices: [Primitive.Index] = []
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

        primitive.append(
            vertices: vertices,
            indices: indices
        )
    }
}
