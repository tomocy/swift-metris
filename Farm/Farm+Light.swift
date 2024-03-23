// tomocy

import Metal

extension Farm {
    struct Lights {
        var ambient: Ambient
        var directional: Directional
        var point: Point
    }
}

extension Farm.Lights {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let raw = Shader.D3.Lights.init(
            ambient: ambient.asLight(),
            directional: directional.asLight(),
            point: point.asLight()
        )

        raw.encode(with: encoder)
    }
}

extension Farm.Lights {
    struct Ambient {
        var color: SIMD3<Float>
        var intensity: Float
    }
}

extension Farm.Lights.Ambient {
    func asLight() -> Shader.D3.Light {
        return .init(
            color: color,
            intensity: intensity,
            aspect: .init(
                projection: .identity,
                view: .identity
            )
        )
    }
}

extension Farm.Lights {
    struct Directional {
        var color: SIMD3<Float>
        var intensity: Float
        var direction: SIMD3<Float>
    }
}

extension Farm.Lights.Directional {
    func asLight() -> Shader.D3.Light {
        return .init(
            color: color,
            intensity: intensity,
            aspect: .init(
                projection: D3.Transform<Float>.orthogonal(
                    top: 1.5, bottom: -1.5,
                    left: -1.5, right: 1.5,
                    near: 0, far: 10
                ).resolve(),
                view: D3.Transform<Float>.look(
                    from: -direction,
                    to: .init(0, 0, 0),
                    up: .init(0, 1, 0)
                )
            )
        )
    }
}

extension Farm.Lights {
    struct Point {
        var color: SIMD3<Float>
        var intensity: Float
        var transform: D3.Transform<Float>
    }
}

extension Farm.Lights.Point {
    func asLight() -> Shader.D3.Light {
        return .init(
            color: color,
            intensity: intensity,
            aspect: .init(
                projection: .identity,
                view: D3.Transform<Float>.look(
                    from: transform.translate,
                    to: .init(0, 0, 0),
                    up: .init(0, 1, 0)
                )
            )
        )
    }
}
