// tomocy

import simd

struct Matrix2D {
    typealias Raw = float3x3

    static let identity: Raw = matrix_identity_float3x3

    static func *(left: Self, right: Self) -> Self {
        return Self(left.raw * right.raw)
    }

    static func translated(with translate: SIMD2<Float>) -> Self {
        return Self(Raw(
            rows: [
                SIMD3(1, 0, translate.x),
                SIMD3(0, 1, translate.y),
                SIMD3(0, 0, 1),
            ]
        ))
    }

    static func rotated(with angle: Angle) -> Self {
        let s = sin(angle.inRadian())
        let c = cos(angle.inRadian())

        return Self(Raw(
            rows: [
                SIMD3(c, -s, 0),
                SIMD3(s, c, 0),
                SIMD3(0, 0, 1),
            ]
        ))
    }

    static func scaled(with scale: SIMD2<Float>) -> Self {
        return Self(Raw(
            rows: [
                SIMD3(scale.x, 0, 0),
                SIMD3(0, scale.y, 0),
                SIMD3(0, 0, 1),
            ]
        ))
    }

    init(_ raw: Raw = identity) {
        self.raw = raw
    }

    var raw: Raw = identity
}
