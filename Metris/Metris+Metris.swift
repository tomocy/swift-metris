// tomocy

enum MetrisX {
    class World {
        init(resolution: SIMD2<Float>) {
            assert(resolution.x != 0 && resolution.y != 0)

            camera = .init(
                projection: Engine.D3.Transform.perspective(
                    near: 0.01, far: 100,
                    aspectRatio: resolution.x / resolution.y, fovY: .pi / 3
                ),
                transform: .init(
                    translate: .init(0, 0.5, -2)
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
        }

        var camera: Engine.D3.Camera
        var lights: Engine.D3.Lights
    }
}
