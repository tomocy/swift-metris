// tomocy

import CoreGraphics

struct Rectangle {
    let size: CGSize
    var color: CGColor = .black()
    var transform: Transform2D = .init()
}

extension Rectangle: IndexedPrimitiveAppendable {
    func append(to primitive: inout IndexedPrimitive) {
        var vertices: [Vertex2D] = []
        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            vertices += [
                .init(at: .init(-halfSize.x, halfSize.y)),
                .init(at: .init(halfSize.x, halfSize.y)),
                .init(at: .init(halfSize.x, -halfSize.y)),
                .init(at: .init(-halfSize.x, -halfSize.y)),
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
                startIndex, startIndex + 1, startIndex + 2,
                startIndex + 2, startIndex + 3, startIndex,
            ]
        }

        primitive.append(
            vertices: vertices,
            indices: indices
        )
    }
}
