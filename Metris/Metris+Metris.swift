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
        }

        var camera: Engine.D3.Camera
    }
}
