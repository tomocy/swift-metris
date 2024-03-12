// tomocy

import CoreGraphics

protocol Vertex: Writable {}

extension D3 {
    struct Vertex<Precision: DimensionalPrecision> {
        var position: Measure = .init(0, 0, 0)
        var color: SIMD4<Float> = .init(0, 0, 0, 1)
        var transform: Transform = .init()
    }
}

extension D3.Vertex {
    typealias Measure = D3.Storage<Precision>
    typealias Transform = D3.Transform<Precision>
}

extension D3.Vertex {
    init(at position: Measure) {
        self.position = position
    }
}

extension D3.Vertex: Vertex {
    func write(to destination: UnsafeMutableRawPointer) {
        withUnsafeBytes(of: self) { body in
            destination.copyMemory(
                from: body.baseAddress!,
                byteCount: body.count
            )
        }
    }
}

extension D3.Vertex {
    mutating func place(at position: Measure) {
        self.position = position
    }

    func placed(at position: Measure) -> Self {
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
