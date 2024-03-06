// tomocy

import CoreGraphics

struct Cube {
    var size: CGVolume = .init(width: 0, height: 0, depth: 0)
    var color: CGColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    var transform: Transform3D = .init()
}

extension Cube: IndexedPrimitive3DAppendable {
    func append(to primitive: inout IndexedPrimitive3D) {
        var vertices: [Vertex3D] = []
        do {
            let halfSize = SIMD3<Float>.init(size) / 2
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

        var indices: [UInt16] = []
        do {
            let startIndex = UInt16(primitive.lastIndex + 1)
            indices += [
                // front
                startIndex, startIndex + 1, startIndex + 2,
                startIndex + 2, startIndex + 3, startIndex,
                // back
                startIndex + 4, startIndex + 5, startIndex + 6,
                startIndex + 6, startIndex + 7, startIndex + 4,
                // left
                startIndex + 1, startIndex + 4, startIndex + 7,
                startIndex + 7, startIndex + 2, startIndex + 1,
                // right
                startIndex + 5, startIndex, startIndex + 3,
                startIndex + 3, startIndex + 6, startIndex + 5,
                // top
                startIndex + 1, startIndex, startIndex + 5,
                startIndex + 5, startIndex + 4, startIndex + 1,
                // bottom
                startIndex + 7, startIndex + 6, startIndex + 3,
                startIndex + 3, startIndex + 2, startIndex + 7,
            ]
        }

        primitive.append(
            vertices: vertices,
            indices: indices
        )
    }
}
