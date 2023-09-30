// tomocy

import CoreGraphics

extension Comparable {
    func clamped(in range: ClosedRange<Self>) -> Self {
        max(min(self, range.upperBound), range.lowerBound)
    }
}

extension UInt {
    func added(_ other: Int, in range: Range<Self>) -> Self {
        assert(self <= Int.max)

        let clamped = Int(self).clamped(in: Int(range.first!)-other...Int(range.last!)-other)
        return Self(clamped + other)
    }
}

extension SIMD2<UInt> {
    func added(_ other: SIMD2<Int>, in range: Vector2D<Range<Self.Scalar>>) -> Self {
        Self(
            self.x.added(other.x, in: range.x),
            self.y.added(other.y, in: range.y)
        )
    }
}

extension SIMD2<Float> {
    init(_ size: CGSize) {
        self.init()

        x = Float(size.width)
        y = Float(size.height)
    }
}


extension SIMD4<Float> {
    init(_ color: CGColor) {
        self.init()

        let c = color.components!
        x = Float(c[0])
        y = Float(c[1])
        z = Float(c[2])
        w = Float(c[3])
    }
}
