    // tomocy

import simd

extension Engine.D3 {
    struct Transform {
        var translate: SIMD3<Float>
        var rotate: SIMD3<Float>
        var scale: SIMD3<Float>
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
