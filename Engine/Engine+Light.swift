// tomocy

import Metal

extension Engine.D3 {
    struct Lights {
        var ambient: Ambient
        var directional: Directional
        var point: Point
    }
}

extension Engine.D3.Lights {
    func encode(in context: some Shader.RenderContext) {
        let raw = Shader.D3.Lights.init(
            ambient: ambient.asLight(),
            directional: directional.asLight(),
            point: point.asLight()
        )

        raw.encode(in: context)
    }
}

extension Engine.D3.Lights {
    struct Ambient {
        var color: SIMD3<Float>
        var intensity: Float
    }
}

extension Engine.D3.Lights.Ambient {
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

extension Engine.D3.Lights {
    struct Directional {
        var color: SIMD3<Float>
        var intensity: Float
        var direction: SIMD3<Float>
    }
}

extension Engine.D3.Lights.Directional {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let raw = asLight()

        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: raw.aspect),
                options: .storageModeShared
            )!
            buffer.label = "Light: Directional: Aspect"

            IO.writable(raw.aspect).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }
    }
}

extension Engine.D3.Lights.Directional {
    func asLight() -> Shader.D3.Light {
        return .init(
            color: color,
            intensity: intensity,
            aspect: .init(
                projection: Engine.D3.Transform.orthogonal(
                    top: 1.5, bottom: -1.5,
                    left: -1.5, right: 1.5,
                    near: 0, far: 10
                ),
                view: Engine.D3.Transform.look(
                    from: -direction,
                    to: .init(0, 0, 0)
                ).inverse
            )
        )
    }
}

extension Engine.D3.Lights {
    struct Point {
        var color: SIMD3<Float>
        var intensity: Float
        var transform: Engine.D3.Transform
    }
}

extension Engine.D3.Lights.Point {
    func asLight() -> Shader.D3.Light {
        return .init(
            color: color,
            intensity: intensity,
            aspect: .init(
                projection: .identity,
                view: Engine.D3.Transform.look(
                    from: transform.translate,
                    to: .init(0, 0, 0)
                )
            )
        )
    }
}
