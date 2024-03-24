// tomocy

import CoreGraphics
import ModelIO
import Metal
import MetalKit

extension MetrisX {
    struct Piece {
        init(
            device: any MTLDevice,
            allocator: any MDLMeshBufferAllocator,
            size: CGVolume,
            color: CGColor,
            position: SIMD2<Int> = .init(0, 0)
        ) {
            self.size = size
            self.position = position

            body = .init(
                raw: try! .init(
                    mesh: .init(
                        boxWithExtent: .init(
                            .init(size.width),
                            .init(size.height),
                            .init(size.depth)
                        ),
                        segments: .init(1, 1, 1),
                        inwardNormals: false,
                        geometryType: .triangles,
                        allocator: allocator
                    ),
                    device: device
                ),
                name: "Piece",
                material: .init(
                    color: App.Engine.Texture.generate(color, with: device)!
                ),
                instances: [
                    .init(
                        transform: .init(
                            scale: .init(repeating: 0.94)
                        )
                    )
                ]
            )
        }

        let size: CGVolume
        var position: SIMD2<Int> = .init(0, 0)
        var body: App.Engine.D3.Mesh
    }
}

extension MetrisX.Piece {
    mutating func place(at position: SIMD2<Int>) {
        self.position = position
    }
}

extension MetrisX.Piece {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let body = Engine.Functional.init(body).state({
            $0.instances[0].transform.translate = .init(
                Float(size.width) * .init(position.x),
                Float(size.height) * .init(position.y),
                0
            )
        }).generate()

        body.encode(with: encoder)
    }
}
