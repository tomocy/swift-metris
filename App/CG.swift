// tomocy

import CoreGraphics

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
