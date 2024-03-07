// tomocy

import CoreGraphics

struct Vertex3D {
    var position: SIMD3<Float> = .init(0, 0, 0)
    var color: SIMD4<Float> = .init(0, 0, 0, 1)
    var transform: Transform = .init()
}

extension Vertex3D {
    typealias Transform = D3.Transform<Float>
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
        return mapState(self) { $0.place(at: position) }
    }

    mutating func colorize(with color: SIMD4<Float>) {
        self.color = color
    }

    func colorized(with color: SIMD4<Float>) -> Self {
        return mapState(self) { $0.colorize(with: color) }
    }

    mutating func transform(with transform: Transform) {
        self.transform = transform
    }

    mutating func transform(by delta: Transform) {
        transform.transform(by: delta)
    }

    func transformed(with transform: Transform) -> Self {
        return mapState(self) { $0.transform(with: transform) }
    }

    func transformed(by delta: Transform) -> Self {
        return mapState(self) { $0.transform(by: delta) }
    }
}
