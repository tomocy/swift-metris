// tomocy

import simd

struct Transform3D {
    var translate: Translate = .init(0, 0, 0)
    var rotate: Rotate = .init(0, 0, 0)
    var scale: Scale = .init(1, 1, 1)
}

extension Transform3D {
    typealias Translate = SIMD3<Float>
    typealias Rotate = SIMD3<Float>
    typealias Scale = SIMD3<Float>
}

extension Transform3D {
    static func orthogonal(top: Float, bottom: Float, left: Float, right: Float, near: Float, far: Float) -> Self {
        return .init(
            translate: .init(
                (left + right) / (left - right),
                (bottom + top) / (bottom - top),
                (near + far) / (near - far)
            ),
            scale: .init(
                2 / (right - left),
                2 / (top - bottom),
                2 / (near - far)
            )
        )
    }
}

extension Transform3D {
    mutating func transform(with transform: Self) {
        translate(with: transform.translate)
    }

    mutating func transform(by delta: Self) {
        translate(by: delta.translate)
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

    mutating func rotate(with rotate: Rotate) {
        self.rotate = rotate
    }

    mutating func rotate(by rotate: Rotate) {
        self.rotate += rotate
    }

    func rotated(with rotate: Rotate) -> Self {
        var next = self
        next.rotate(with: rotate)
        return next
    }

    func rotated(by rotate: Rotate) -> Self {
        var next = self
        next.rotate(by: rotate)
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
