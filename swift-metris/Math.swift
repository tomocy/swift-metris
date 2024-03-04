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

extension SIMD2<UInt> {
    init(_ other: SIMD2<Int>) {
        self.init(
            x: .init(other.x),
            y: .init(other.y)
        )
    }
}

extension SIMD2<Float> {
    init(_ size: CGSize) {
        self.init()

        x = .init(size.width)
        y = .init(size.height)
    }
}


extension SIMD4<Float> {
    init(_ color: CGColor) {
        self.init()

        guard let c = color.components else { return }
        x = .init(c[0])
        y = .init(c[1])
        z = .init(c[2])
        w = .init(c[3])
    }
}
