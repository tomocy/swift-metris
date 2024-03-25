// tomocy

import CoreGraphics

extension CGSize {
    func min() -> CGFloat { Swift.min(width, height) }
}

extension SIMD2<Float> {
    init(_ size: CGSize) {
        self.init()

        x = .init(size.width)
        y = .init(size.height)
    }
}

struct CGVolume {
    var width: CGFloat = 0
    var height: CGFloat = 0
    var depth: CGFloat = 0
}

extension CGColor {
    static func random(red: CGFloat? = nil, green: CGFloat? = nil, blue: CGFloat? = nil, alpha: CGFloat? = nil) -> Self {
        return .init(
            red: red ?? .random(in: 0...1),
            green: green ?? .random(in: 0...1),
            blue: blue ?? .random(in: 0...1),
            alpha: alpha ?? .random(in: 0...1)
        )
    }

    static func black(alpha: CGFloat = 1) -> Self {
        return .init(
            red: 0,
            green: 0,
            blue: 0,
            alpha: alpha
        )
    }

    var red: CGFloat { components?[0] ?? 0 }
    var green: CGFloat { components?[1] ?? 0 }
    var blue: CGFloat { components?[2] ?? 0 }
    var alpha: CGFloat { components?[3] ?? 0 }
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
