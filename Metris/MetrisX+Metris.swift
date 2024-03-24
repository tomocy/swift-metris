// tomocy

import Metal
import MetalKit

enum MetrisX {
    class World {
        init(device: any MTLDevice, resolution: SIMD2<Float>) {
            assert(resolution.x != 0 && resolution.y != 0)

            camera = .init(
                projection: Engine.D3.Transform.perspective(
                    near: 0.01, far: 100,
                    aspectRatio: resolution.x / resolution.y, fovY: .pi / 3
                ),
                transform: .init(
                    translate: .init(0, 0, -2)
                )
            )

            lights = .init(
                ambient: .init(
                    color: .init(1, 1, 1),
                    intensity: 0.1
                ),
                directional: .init(
                    color: .init(1, 1, 1),
                    intensity: 0.8,
                    direction: .init(-1, -1, 1)
                ),
                point: .init(
                    color: .init(0.95, 0, 0),
                    intensity: 0.8,
                    transform: .init(
                        translate: .init(-0.5, 1, -0.5)
                    )
                )
            )

            do {
                let allocator = MTKMeshBufferAllocator.init(device: device)

                piece = .init(
                    raw: try! .init(
                        mesh: .init(
                            boxWithExtent: .init(0.75, 0.75, 0.75),
                            segments: .init(1, 1, 1),
                            inwardNormals: false,
                            geometryType: .triangles,
                            allocator: allocator
                        ),
                        device: device
                    ),
                    name: "Piece",
                    material: .init(
                        color: Engine.Texture.generate(
                            .init(red: 0.1, green: 0.94, blue: 0.3, alpha: 1),
                            with: device
                        )!
                    ),
                    instances: [
                        .init(
                            transform: .init(translate: .init(0, 0, 0))
                        )
                    ]
                )
            }
        }

        var camera: Engine.D3.Camera
        var lights: Engine.D3.Lights

        var piece: Engine.D3.Mesh
    }
}

extension MetrisX.World: Shader.D3.Shadow.Encodable {
    func encode(with encoder: Shader.D3.Shadow.Encoder) {
        lights.directional.encode(with: encoder.raw)

        do {
            piece.encode(with: encoder.raw)
        }
    }
}

extension MetrisX.World: Shader.D3.Mesh.Encodable {
    func encode(with encoder: Shader.D3.Mesh.Encoder) {
        camera.encode(with: encoder.raw)
        lights.encode(with: encoder.raw)

        do {
            piece.encode(with: encoder.raw)
        }
    }
}

