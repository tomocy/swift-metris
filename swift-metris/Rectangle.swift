// tomocy

import Foundation

struct Rectangle {
    func append(to primitive: inout IndexedPrimitive) {
        let halfSize = SIMD2<Float>(Float(size.width / 2), Float(size.height / 2))

        let startIndex = UInt16(primitive.lastIndex + 1)

        primitive.append(
            vertices: [
                Vertex(SIMD2(-halfSize.x, halfSize.y)),
                Vertex(SIMD2(halfSize.x, halfSize.y)),
                Vertex(SIMD2(halfSize.x, -halfSize.y)),
                Vertex(SIMD2(-halfSize.x, -halfSize.y)),
            ].map({ v in v.tranform(by: transform) }),
            indices: [
                startIndex, startIndex + 1, startIndex + 2,
                startIndex + 2, startIndex + 3, startIndex,
            ]
        )
    }

    let size: CGSize
    var transform: Transform2D = Transform2D()
}
