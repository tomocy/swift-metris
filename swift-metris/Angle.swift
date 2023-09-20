// tomocy

struct Angle {
    static func +(left: Self, right: Self) -> Self {
        return Self(radian: left.raw + right.raw)
    }

    static func *(left: Self, right: Self) -> Self {
        return Self(radian: left.raw * right.raw)
    }

    static func *(left: Self, right: Float) -> Self {
        return Self(radian: left.raw * right)
    }

    static func +=(left: inout Self, right: Self) {
        left = left + right
    }

    static func *=(left: inout Self, right: Self) {
        left = left * right
    }

    static func *=(left: inout Self, right: Float) {
        left = left * right
    }

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

    // The raw value is stored in radian.
    private var raw: Float = 0
}
