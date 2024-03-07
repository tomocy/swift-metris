// tomocy

import simd

extension D3 {
    struct Transform<Precision: DimensionalPrecision> {
        var translate: Measure = .init(0, 0, 0)
        var rotate: Measure = .init(0, 0, 0)
        var scale: Measure = .init(0, 0, 0)
    }
}

extension D3.Transform {
    typealias Measure = D3.Storage<Precision>
}

extension D3.Transform {
    static func orthogonal(
        top: Precision, bottom: Precision,
        left: Precision, right: Precision,
        near: Precision, far: Precision
    ) -> Self {
        return .init(
            translate: Measure.init(
                (left + right) / -2,
                (bottom + top) / -2,
                (near + far) / -2
            ),
            scale: Measure.init(
                2 / (right - left),
                2 / (top - bottom),
                2 / (near - far)
            )
        )
    }
}

extension D3.Transform {
    mutating func translate(with translate: Measure) {
        self.translate = translate
    }

    mutating func translate(by delta: Measure) {
        self.translate += delta
    }

    func translated(with translate: Measure) -> Self {
        return mapState(self) { $0.translate(with: translate) }
    }

    func translated(by delta: Measure) -> Self {
        return mapState(self) { $0.translate(by: delta) }
    }
}

extension D3.Transform {
    mutating func rotate(with rotate: Measure) {
        self.rotate = rotate
    }

    mutating func rotate(by delta: Measure) {
        self.rotate += delta
    }

    func rotated(with rotate: Measure) -> Self {
        return mapState(self) { $0.rotate(with: rotate) }
    }

    func rotated(by delta: Measure) -> Self {
        return mapState(self) { $0.rotate(by: delta) }
    }
}

extension D3.Transform {
    mutating func scale(with scale: Measure) {
        self.scale = scale
    }

    mutating func scale(by delta: Measure) {
        self.scale *= delta
    }

    func scaled(with scale: Measure) -> Self {
        return mapState(self) { $0.scale(with: scale) }
    }

    func scaled(by delta: Measure) -> Self {
        return mapState(self) { $0.scale(by: delta) }
    }
}

extension D3.Transform {
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
        return mapState(self) {
            $0.inverse(translate: translate, rotate: rotate, scale: scale)
        }
    }
}

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
                (left + right) / -2,
                (bottom + top) / -2,
                (near + far) / -2
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
        return mapState(self) { $0.transform(with: transform) }
    }

    func transformed(by delta: Self) -> Self {
        return mapState(self) { $0.transform(by: delta) }
    }

    mutating func translate(with translate: Translate) {
        self.translate = translate
    }

    mutating func translate(by delta: Translate) {
        self.translate += delta
    }

    func translated(with translate: Translate) -> Self {
        return mapState(self) { $0.translate(with: translate) }
    }

    func translated(by delta: Translate) -> Self {
        return mapState(self) { $0.translate(by: delta) }
    }

    mutating func rotate(with rotate: Rotate) {
        self.rotate = rotate
    }

    mutating func rotate(by delta: Rotate) {
        self.rotate += delta
    }

    func rotated(with rotate: Rotate) -> Self {
        return mapState(self) { $0.rotate(with: rotate) }
    }

    func rotated(by delta: Rotate) -> Self {
        return mapState(self) { $0.rotate(by: delta) }
    }

    mutating func scale(with scale: Scale) {
        self.scale = scale
    }

    mutating func scale(by delta: Scale) {
        self.scale *= delta
    }

    func scaled(with scale: Scale) -> Self {
        return mapState(self) { $0.scale(with: scale) }
    }

    func scaled(by delta: Scale) -> Self {
        return mapState(self) { $0.scale(by: delta) }
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
        return mapState(self) {
            $0.inverse(translate: translate, rotate: rotate, scale: scale)
        }
    }
}
