// tomocy

import CoreGraphics

extension Comparable {
    func clamped(in range: ClosedRange<Self>) -> Self {
        return max(
            min(self, range.upperBound),
            range.lowerBound
        )
    }
}

extension SIMD2 where Scalar: Comparable {
    func min(_ other: Self) -> Self {
        return .init(
            Swift.min(x, other.x),
            Swift.min(y, other.y)
        )
    }

    func max(_ other: Self) -> Self {
        return .init(
            Swift.max(x, other.x),
            Swift.max(y, other.y)
        )
    }
}
