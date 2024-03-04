// tomocy

import CoreGraphics

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
}
