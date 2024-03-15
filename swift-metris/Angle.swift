// tomocy

struct Angle {
    typealias Raw = Float

    init(degree: Raw) {
        raw = degree * .pi / 180
    }

    init(radian: Raw) {
        raw = radian
    }

    func inDegree() -> Raw {
        return raw * 180 / .pi
    }

    func inRadian() -> Raw {
        return raw
    }

    // The raw value is stored in radian.
    private var raw: Raw = 0
}

extension Angle: AdditiveArithmetic, Comparable {
    static var zero: Self { .init(radian: Raw.zero) }

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
