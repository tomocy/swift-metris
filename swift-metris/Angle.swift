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

extension Angle : SignedNumeric {
    typealias Magnitude = Raw.Magnitude
    typealias IntegerLiteralType = Raw.IntegerLiteralType

    static func +(left: Self, right: Self) -> Self {
        Self(radian: left.raw + right.raw)
    }

    static func -(left: Self, right: Self) -> Self {
        Self(radian: left.raw - right.raw)
    }

    static func *(left: Self, right: Self) -> Self {
        Self(radian: left.raw * right.raw)
    }

    static func *=(left: inout Self, right: Self) {
        left = left * right
    }

    init(integerLiteral value: Raw.IntegerLiteralType) {
        self.init(degree: .init(integerLiteral: value))
    }

    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let radian = Raw.init(exactly: source) else { return nil }
        self.init(radian: radian)
    }

    var magnitude: Raw.Magnitude { raw.magnitude }
}
