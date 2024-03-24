// tomocy

extension Engine {
    struct Angle {
        // The raw value is stored in radian.
        private var raw: Float = 0
    }
}

extension Engine.Angle {
    init(degree: Float) {
        raw = degree * .pi / 180
    }

    init(radian: Float) {
        raw = radian
    }

    func inDegree() -> Float {
        return raw * 180 / .pi
    }

    func inRadian() -> Float {
        return raw
    }
}

extension Engine.Angle: AdditiveArithmetic, Comparable {
    static var zero: Self { .init(radian: Float.zero) }

    static func +(left: Self, right: Self) -> Self {
        return .init(radian: left.raw + right.raw)
    }

    static func -(left: Self, right: Self) -> Self {
        return .init(radian: left.raw - right.raw)
    }

    static func <(left: Self, right: Self) -> Bool {
        return left.raw < right.raw
    }
}
