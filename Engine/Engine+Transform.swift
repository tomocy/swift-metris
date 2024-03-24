    // tomocy

import simd

extension Engine.D3 {
    struct Transform {
        var translate: SIMD3<Float> = .init()
        var rotate: SIMD3<Float> = .init()
        var scale: SIMD3<Float> = .init(repeating: 1)
    }
}

extension Engine.D3.Transform {
    static func orthogonal(
        top: Float, bottom: Float,
        left: Float, right: Float,
        near: Float, far: Float
    ) -> float4x4 {
        // Note that
        // in Metal, unlike x and y axes where values are mapped into -1...1,
        // values on z-axis is into 0...1.

        let translate: SIMD3<Float> = .init(
            (right + left) / (right - left),
            (top + bottom) / (top - bottom),
            near / (far - near)
        )

        let scale: SIMD3<Float> = .init(
            (1 - -1)  / (right - left),
            (1 - -1) / (top - bottom),
            (1 - 0) / (far - near)
        )

        return Self.translate(translate)
            * Self.scale(scale)
    }

    static func perspective(
        near: Float, far: Float,
        aspectRatio: Float, fovY: Float
    ) -> float4x4 {
        var scale = SIMD2<Float>.init(1, 1)
        scale.y = 1 / tan(fovY / 2)
        scale.x = scale.y * (1 / aspectRatio) // 1 / w = (1 / h) * (h / w)

        return .init(
            rows: [
                .init(scale.x, 0, 0, 0),
                .init(0, scale.y, 0, 0),
                .init(0, 0, far / (far - near), -(far * near) / (far - near)),
                .init(0, 0, 1, 0)
            ]
        )
    }
}

extension Engine.D3.Transform {
    func resolved() -> float4x4 {
        return Self.translate(translate)
            * Self.rotate(rotate)
            * Self.scale(scale)
    }
}

extension Engine.D3.Transform {
    static func translate(_ translate: SIMD3<Float>) -> float4x4 {
        return .init(
            rows: [
                .init(1, 0, 0, translate.x),
                .init(0, 1, 0, translate.y),
                .init(0, 0, 1, translate.z),
                .init(0, 0, 0, 1)
            ]
        )
    }

    static func rotate(_ rotate: SIMD3<Float>) -> float4x4 {
        return Self.rotate(.init(radian: rotate.x), around: .x)
            * Self.rotate(.init(radian: rotate.y), around: .y)
            * Self.rotate(.init(radian: rotate.z), around: .z)
    }

    static func rotate(_ angle: Engine.Angle, around axis: Engine.D3.Axis) -> float4x4 {
        let degree = angle.inRadian()
        let (s, c) = (sin(degree), cos(degree))

        switch axis {
        case .x:
            return .init(
                rows: [
                    .init(1, 0, 0, 0),
                    .init(0, c, -s, 0),
                    .init(0, s, c, 0),
                    .init(0, 0, 0, 1)
                ]
            )
        case .y:
            return .init(
                rows: [
                    .init(c, 0, s, 0),
                    .init(0, 1, 0, 0),
                    .init(-s, 0, c, 0),
                    .init(0, 0, 0, 1)
                ]
            )
        case .z:
            return .init(
                rows: [
                    .init(c, -s, 0, 0),
                    .init(s, c, 0, 0),
                    .init(0, 0, 1, 0),
                    .init(0, 0, 0, 1)
                ]
            )
        }
    }

    static func scale(_ scale: SIMD3<Float>) -> float4x4 {
        return .init(
            rows: [
                .init(scale.x, 0, 0, 0),
                .init(0, scale.y, 0, 0),
                .init(0, 0, scale.z, 0),
                .init(0, 0, 0, 1)
            ]
        )
    }
}
