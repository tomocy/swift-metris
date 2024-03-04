// tomocy

import CoreGraphics

struct Vertex {
    var position: Transform2D.Translate = .init(0, 0)
    var color: SIMD4<Float> = .init(0, 0, 0, 1)
    var transform: Transform2D = .init()
}

extension Vertex {
    init(at position: Transform2D.Translate) {
        self.position = position
    }
}

extension Vertex {
    mutating func position(at position: Transform2D.Translate) {
        self.position = position
    }

    func positioned(at position: Transform2D.Translate) -> Self {
        var x = self
        x.position(at: position)
        return x
    }

    mutating func colorize(with color: SIMD4<Float>) {
        self.color = color
    }

    func colorized(with color: SIMD4<Float>) -> Self {
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
}
