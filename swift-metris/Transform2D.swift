// tomocy

import simd
import Metal

struct Transform2D {
    static func orthogonal(top: Float, bottom: Float, left: Float, right: Float) -> Self {
        // In MSL, NDC has (0, 0) at the center, (-1, -1) at the bottom left, and (1, 1) at the top right.

        return Transform2D(
            translate: SIMD2(
                (left + right) / (left - right),
                (bottom + top) / (bottom - top)
            ),
            scale: SIMD2(
                2 / (right - left),
                2 / (top - bottom)
            )
        )
    }

    func rotated(degree: Float) -> Self {
        var x = self
        x.rotate(degree: degree)
        return x
    }

    mutating func rotate(degree: Float) {
        self.rotate = degree * .pi / 180
    }

    func apply() -> Matrix2D {
        let matrix = [
            Matrix2D.scale(scale),
            Matrix2D.rotate(rotate),
            Matrix2D.translate(translate),
        ]

        return Matrix2D(matrix.reduce(Matrix2D.identity) { matrix, current in current * matrix })
    }

    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        let matrix = apply()
        matrix.encode(with: encoder, at: index)
    }

    var translate: SIMD2<Float> = SIMD2(0, 0)
    var rotate: Float = 0
    var scale: SIMD2<Float> = SIMD2(1, 1)
}
