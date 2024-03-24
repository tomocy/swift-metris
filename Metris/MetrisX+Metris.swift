// tomocy

import Metal
import MetalKit

enum MetrisX {
    class World {
        init(device: any MTLDevice, resolution: SIMD2<Float>) {
            assert(resolution.x != 0 && resolution.y != 0)

            camera = .init(
                projection: App.Engine.D3.Transform.perspective(
                    near: 0.01, far: 100,
                    aspectRatio: resolution.x / resolution.y, fovY: .pi / 3
                ),
                transform: .init(
                    translate: .init(0.25, 0.5, -1)
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

            engine = .init(
                device: device,
                allocator: MTKMeshBufferAllocator.init(device: device),
                size: .init(width: 0.5, height: 1)
            )
            engine.start()
        }

        var camera: App.Engine.D3.Camera
        var lights: App.Engine.D3.Lights

        var engine: Engine
    }
}

extension MetrisX.World: Shader.D3.Shadow.Encodable {
    func encode(with encoder: Shader.D3.Shadow.Encoder) {
        lights.directional.encode(with: encoder.raw)

        engine.encode(with: encoder.raw)
    }
}

extension MetrisX.World: Shader.D3.Mesh.Encodable {
    func encode(with encoder: Shader.D3.Mesh.Encoder) {
        camera.encode(with: encoder.raw)
        lights.encode(with: encoder.raw)

        engine.encode(with: encoder.raw)
    }
}

