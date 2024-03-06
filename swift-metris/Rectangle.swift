// tomocy

import CoreGraphics

struct Rectangle {
    let size: CGSize
    var color: CGColor = .black()
    var transform: Transform2D = .init()
}

extension Rectangle: IndexedPrimitive3DAppendable {
    func append(to primitive: inout IndexedPrimitive3D) {
        var vertices: [Vertex3D] = []
        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            vertices += [
                /* 0 */ .init(at: .init(-halfSize.x, halfSize.y, 0)),
                /* 1 */ .init(at: .init(halfSize.x, halfSize.y, 0)),
                /* 2 */ .init(at: .init(halfSize.x, -halfSize.y, 0)),
                /* 3 */ .init(at: .init(-halfSize.x, -halfSize.y, 0)),
            ]

            vertices = vertices.map({
                $0.colorized(with: .init(color))
            }).map({
                $0.transformed(
                    with: .init(
                        translate: .init(transform.translate, 0),
                        rotate: .init(0, 0, transform.rotate.inRadian()),
                        scale: .init(transform.scale, 1)
                    )
                )
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
