// tomocy

import Metal
import MetalKit

enum Metris {
    class World {
        init(device: any MTLDevice, resolution: CGSize) {
            camera = .init(
                projection: App.Engine.D3.Transform.perspective(
                    near: 0.01, far: 100,
                    aspectRatio: .init(resolution.width / resolution.height), fovY: .pi / 3
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

extension Metris.World: Engine.View.Target {
    func tick(delta: Float) {}
}

extension Metris.World: Shader.D3.Shadow.Encodable {
    func encode(in context: Shader.D3.Shadow.Context) {
        lights.directional.encode(in: context)
        engine.encode(in: context)
    }
}

extension Metris.World: Shader.D3.Mesh.Encodable {
    func encode(in context: Shader.D3.Mesh.Context) {
        camera.encode(in: context)
        lights.encode(in: context)

        engine.encode(in: context)
    }
}

extension Metris.World {
    func keyDown(with event: NSEvent) {
        engine.keyDown(with: event)
    }
}
