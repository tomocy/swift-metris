// tomocy

import CoreGraphics

extension Comparable {
    func clamped(in range: ClosedRange<Self>) -> Self {
        max(min(self, range.upperBound), range.lowerBound)
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
