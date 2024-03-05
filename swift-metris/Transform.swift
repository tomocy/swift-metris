// tomocy

import simd

struct Transform2D {
    var translate: Translate = .init(0, 0)
    var rotate: Angle = .init(radian: 0)
    var scale: Scale = .init(1, 1)
}

extension Transform2D {
    typealias Translate = SIMD2<Float>
    typealias Scale = SIMD2<Float>
}

extension Transform2D {
    init(_ other: Self) {
        translate = other.translate
        rotate = other.rotate
        scale = other.scale
    }
}

extension Transform2D {
    static func orthogonal(top: Float, bottom: Float, left: Float, right: Float) -> Self {
        // In MSL, NDC has (0, 0) at the center, (-1, -1) at the bottom left, and (1, 1) at the top right.

        return .init(
            translate: .init(
                (left + right) / (left - right),
                (bottom + top) / (bottom - top)
            ),
            scale: .init(
                2 / (right - left),
                2 / (top - bottom)
            )
        )
    }
}

extension Transform2D {
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
        var next = self
        next.transform(with: transform)
        return next
    }

    func transformed(by delta: Self) -> Self {
        var next = self
        next.transform(by: delta)
        return next
    }

    mutating func translate(with translate: Translate) {
        self.translate = translate
    }

    mutating func translate(by delta: Translate) {
        self.translate += delta
    }

    func translated(with translate: Translate) -> Self {
        var next = self
        next.translate(with: translate)
        return next
    }

    func translated(by delta: Translate) -> Self {
        var next = self
        next.translate(by: delta)
        return next
    }

    mutating func rotate(with angle: Angle) {
        self.rotate = angle;
    }

    mutating func rotate(by angle: Angle) {
        self.rotate += angle
    }

    func rotated(with angle: Angle) -> Self {
        var next = self
        next.rotate(with: angle)
        return next
    }

    func rotated(by angle: Angle) -> Self {
        var next = self
        next.rotate(by: angle)
        return next
    }

    mutating func scale(with scale: Scale) {
        self.scale = scale
    }

    mutating func scale(by factor: Scale) {
        self.scale *= scale
    }

    func scaled(with factor: Scale) -> Self {
        var next = self
        next.scale(with: factor)
        return next
    }

    func scaled(by factor: Scale) -> Self {
        var next = self
        next.scale(by: factor)
        return next
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
        var next = self
        next.inverse(translate: translate, rotate: rotate, scale: scale)
        return next
    }
}

struct Transform3D {
    var translate: Translate = .init(0, 0, 0)
}

extension Transform2D {
    typealias Translate = SIMD3<Float>
}

