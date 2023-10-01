// tomocy

import CoreGraphics

extension Comparable {
    func clamped(in range: ClosedRange<Self>) -> Self {
        max(min(self, range.upperBound), range.lowerBound)
    }
}

extension SIMD2 where Scalar: Comparable {
    func min(_ other: Self) -> Self {
        Self(
            Swift.min(x, other.x),
            Swift.min(y, other.y)
        )
    }

    func max(_ other: Self) -> Self {
        Self(
            Swift.max(x, other.x),
            Swift.max(y, other.y)
        )
    }
}

extension SIMD2<UInt> {
    init(_ other: SIMD2<Int>) {
        self.init(x: UInt(other.x), y: UInt(other.y))
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
