// tomocy

import CoreGraphics
import Metal

struct Vertex {
    mutating func position(at position: SIMD2<Float>) {
        self.position = position
    }

    func positioned(at position: SIMD2<Float>) -> Self {
        var x = self
        x.position(at: position)
        return x
    }

    mutating func colorize(with color: SIMD4<Float>) {
        self.color = color
    }

    mutating func colorize(with color: CGColor) {
        colorize(with: SIMD4(color))
    }

    func colorized(with color: SIMD4<Float>) -> Self {
        var x = self
        x.colorize(with: color)
        return x
    }

    func colorized(with color: CGColor) -> Self {
        var x = self
        x.colorize(with: color)
        return x
    }

    mutating func transform(with transform: Transform2D) {
        self.transform = transform
    }

    mutating func transform(by delta: Transform2D) {
        transform.transform(by: delta)
    }

    func transformed(with transform: Transform2D) -> Self {
        var x = self
        x.transform(with: transform)
        return x
    }

    func transformed(by delta: Transform2D) -> Self {
        var x = self
        x.transform(by: delta)
        return x
    }

    var position: SIMD2<Float> = SIMD2(0, 0)
    var color: SIMD4<Float> = SIMD4(0, 0, 0, 1)
    var transform: Transform2D = Transform2D()
};

extension Vertex {
    init(_ position: SIMD2<Float>) {
        self.position = position
    }
}
