// tomocy

import simd

extension D3 {
    struct Transform<P: Dimension.Precision> {
        var translate: Measure = .init(0, 0, 0)
        var rotate: Measure = .init(0, 0, 0)
        var scale: Measure = .init(1, 1, 1)
    }
}

extension D3.Transform {
    typealias Precision = P
    typealias Measure = D3.Storage<Precision>
}

extension D3.Transform {
    static func orthogonal(for size: SIMD2<Precision>) -> Self {
        let halfSize = size / 2

        return .orthogonal(
            top: halfSize.y, bottom: -halfSize.y,
            left: -halfSize.x, right: halfSize.x,
            near: 0, far: halfSize.max()
        )
    }

    static func orthogonal(
        top: Precision, bottom: Precision,
        left: Precision, right: Precision,
        near: Precision, far: Precision
    ) -> Self {
        // In Metal, unlike x and y axes where values are mapped into -1...1,
        // values on z-axis is into 0...1.
        // Therefore, translate and scale for z-axis should be less accordingly.

        return .init(
            translate: Measure.init(
                (right + left) / (right - left),
                (top + bottom) / (top - bottom),
                near / (far - near)
            ),
            scale: Measure.init(
                (1 - -1)  / (right - left),
                (1 - -1) / (top - bottom),
                (1 - 0) / (far - near)
            )
        )
    }
}

extension D3.Transform {
    func resolve() -> D3.Matrix {
        let translate = D3.Matrix.translate(translate)

        let rotate = D3.Matrix.rotate(rotate, around: .x)
                * D3.Matrix.rotate(rotate, around: .y)
                * D3.Matrix.rotate(rotate, around: .z)

        let scale = D3.Matrix.scale(scale)

        return translate * rotate * scale
    }
}

extension D3.Transform {
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
        return mapState(self) { $0.transform(with: transform) }
    }

    func transformed(by delta: Self) -> Self {
        return mapState(self) { $0.transform(by: delta) }
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

extension D3.Matrix {
    init(columns: [SIMD4<Float>]) {
        self.init(
            columns: (columns[0], columns[1], columns[2], columns[3])
        )
    }
}

extension D3.Matrix {
    static func translate<P: Dimension.Precision>(_ translate: D3.Storage<P>) -> Self {
        let columns: [SIMD4<Float>] = [
            .init(1, 0, 0, 0),
            .init(0, 1, 0, 0),
            .init(0, 0, 1, 0),
            .init(.init(translate.x), .init(translate.y), .init(translate.z), 1)
        ]

        return .init(columns)
    }

    static func rotate<P: Dimension.Precision>(_ rotate: D3.Storage<P>, around axis: D3.Axis) -> Self {
        switch axis {
        case .x:
            let degree: Float = .init(rotate.x)
            let (s, c) = (sin(degree), cos(degree))

            let columns: [SIMD4<Float>] = [
                .init(1, 0, 0, 0),
                .init(0, c, s, 0),
                .init(0, -s, c, 0),
                .init(0, 0, 0, 1)
            ]

            return .init(columns)
        case .y:
            let degree: Float = .init(rotate.y)
            let (s, c) = (sin(degree), cos(degree))

            let columns: [SIMD4<Float>] = [
                .init(c, 0, -s, 0),
                .init(0, 1, 0, 0),
                .init(s, 0, c, 0),
                .init(0, 0, 0, 1)
            ]

            return .init(columns)
        case .z:
            let degree: Float = .init(rotate.z)
            let (s, c) = (sin(degree), cos(degree))

            let columns: [SIMD4<Float>] = [
                .init(c, s, 0, 0),
                .init(-s, c, 0, 0),
                .init(0, 0, 1, 0),
                .init(0, 0, 0, 1)
            ]

            return .init(columns)
        }
    }

    static func scale<P: Dimension.Precision>(_ scale: D3.Storage<P>) -> Self {
        let columns: [SIMD4<Float>] = [
            .init(.init(scale.x), 0, 0, 0),
            .init(0, .init(scale.y), 0, 0),
            .init(0, 0, .init(scale.z), 0),
            .init(0, 0, 0, 1)
        ]

        return .init(columns)
    }
}
