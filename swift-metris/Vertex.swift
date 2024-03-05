// tomocy

import CoreGraphics

struct Vertex2D {
    var position: SIMD2<Float> = .init(0, 0)
    var color: SIMD4<Float> = .init(0, 0, 0, 1)
    var transform: Transform2D = .init()
}

extension Vertex2D {
    init(at position: SIMD2<Float>) {
        self.position = position
    }
}

extension Vertex2D {
    mutating func place(at position: SIMD2<Float>) {
        self.position = position
    }

    func placed(at position: SIMD2<Float>) -> Self {
        var next = self
        next.place(at: position)
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

struct Vertex3D {
    var position: SIMD3<Float> = .init(0, 0, 0)
    var color: SIMD4<Float> = .init(0, 0, 0, 1)
    var transform: Transform3D = .init()
}

extension Vertex3D {
    init(at position: SIMD3<Float>) {
        self.position = position
    }
}

extension Vertex3D {
    mutating func colorize(with color: SIMD4<Float>) {
        self.color = color
    }

    func colorized(with color: SIMD4<Float>) -> Self {
        var next = self
        next.colorize(with: color)
        return next
    }
}
