// tomocy

import simd
import Metal

struct Matrix2D {
    typealias Raw = float3x3

    static func translate(_ delta: SIMD2<Float>) -> Raw {
        return Raw(
            rows: [
                SIMD3(1, 0, delta.x),
                SIMD3(0, 1, delta.y),
                SIMD3(0, 0, 1),
            ]
        )
    }

    static func rotate(_ radian: Float) -> Raw {
        let s = sin(radian)
        let c = cos(radian)

        return Raw(
            rows: [
                SIMD3(c, -s, 0),
                SIMD3(s, c, 0),
                SIMD3(0, 0, 1),
            ]
        )
    }

    static func scale(_ factor: SIMD2<Float>) -> Raw {
        return Raw(
            rows: [
                SIMD3(factor.x, 0, 0),
                SIMD3(0, factor.y, 0),
                SIMD3(0, 0, 1),
            ]
        )
    }

    static let identity: Raw = matrix_identity_float3x3

    init(_ raw: Raw = identity) {
        self.raw = raw
    }

    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        var bytes = raw
        let buffer = encoder.device.makeBuffer(
            bytes: &bytes,
            length: MemoryLayout<Raw>.stride,
            options: .storageModeShared
        )

        encoder.setVertexBuffer(buffer, offset: 0, index: index)
    }

    var raw: Raw = identity
}

