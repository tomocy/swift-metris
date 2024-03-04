// tomocy

import CoreGraphics

struct Vertex {
    var position: SIMD2<Float> = .init(0, 0)
    var color: SIMD4<Float> = .init(0, 0, 0, 1)
    var transform: Transform2D = .init()
}

extension Vertex {
    init(at position: SIMD2<Float>) {
        self.position = position
    }
}

extension Vertex {
    mutating func position(at position: SIMD2<Float>) {
        self.position = position
    }

    func positioned(at position: SIMD2<Float>) -> Self {
        var next = self
        next.position(at: position)
        return next
    }

    mutating func colorize(with color: SIMD4<Float>) {
        self.color = color
    }

    func colorized(with color: SIMD4<Float>) -> Self {
        var next = self
        next.colorize(with: color)
        return next
    }

    mutating func transform(with transform: Transform2D) {
        self.transform = transform
    }

    mutating func transform(by delta: Transform2D) {
        transform.transform(by: delta)
    }

    func transformed(with transform: Transform2D) -> Self {
        var next = self
        next.transform(with: transform)
        return next
    }

    func transformed(by delta: Transform2D) -> Self {
        var next = self
        next.transform(by: delta)
        return next
    }
}
