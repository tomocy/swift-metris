// tomocy

import CoreGraphics

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
    mutating func place(at position: SIMD3<Float>) {
        self.position = position
    }

    func placed(at position: SIMD3<Float>) -> Self {
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

    mutating func transform(with transform: Transform3D) {
        self.transform = transform
    }

    mutating func transform(by delta: Transform3D) {
        transform.transform(by: delta)
    }

    func transformed(with transform: Transform3D) -> Self {
        var next = self
        next.transform(with: transform)
        return next
    }

    func transformed(by delta: Transform3D) -> Self {
        var next = self
        next.transform(by: delta)
        return next
    }
}
