// tomocy

import simd

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

    mutating func transform(with transform: Self) {
        translate(with: transform.translate)
        rotate(with: transform.rotate)
        scale(with: transform.scale)
    }

    mutating func transform(by delta: Self) {
        translate(by: delta.translate)
        rotate(by: delta.rotate)
        scale(by: delta.scale)
    }

    func transformed(with transform: Self) -> Self {
        var x = self
        x.transform(with: transform)
        return x
    }

    func transformed(by delta: Self) -> Self {
        var x = self
        x.transform(by: delta)
        return x
    }

    mutating func translate(with translate: SIMD2<Float>) {
        self.translate = translate
    }

    mutating func translate(by delta: SIMD2<Float>) {
        self.translate += delta
    }

    func translated(with translate: SIMD2<Float>) -> Self {
        var x = self
        x.translate(with: translate)
        return x
    }

    func translated(by delta: SIMD2<Float>) -> Self {
        var x = self
        x.translate(by: delta)
        return x
    }

    mutating func rotate(with angle: Angle) {
        self.rotate = angle;
    }

    mutating func rotate(by angle: Angle) {
        self.rotate += angle
    }

    func rotated(with angle: Angle) -> Self {
        var x = self
        x.rotate(with: angle)
        return x
    }

    func rotated(by angle: Angle) -> Self {
        var x = self
        x.rotate(by: angle)
        return x
    }

    mutating func scale(with scale: SIMD2<Float>) {
        self.scale = scale
    }

    mutating func scale(by factor: SIMD2<Float>) {
        self.scale *= scale
    }

    func scaled(with factor: SIMD2<Float>) -> Self {
        var x = self
        x.scale(with: factor)
        return x
    }

    func scaled(by factor: SIMD2<Float>) -> Self {
        var x = self
        x.scale(by: factor)
        return x
    }

    mutating func inverse(translate: Bool = true, rotate: Bool = true, scale: Bool = true) {
        if (translate) {
            self.translate *= -1
        }

        if (rotate) {
            self.rotate *= -1
        }

        if (scale) {
            self.scale *= -1
        }
    }

    func inversed(translate: Bool = true, rotate: Bool = true, scale: Bool = true) -> Self {
        var x = self
        x.inverse(translate: translate, rotate: rotate, scale: scale)
        return x
    }

    var translate: SIMD2<Float> = .init(0, 0)
    var rotate: Angle = .init(radian: 0)
    var scale: SIMD2<Float> = .init(1, 1)
}

extension Transform2D {
    init(_ other: Self) {
        translate = other.translate
        rotate = other.rotate
        scale = other.scale
    }
}
