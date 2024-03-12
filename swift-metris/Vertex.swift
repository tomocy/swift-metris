// tomocy

import CoreGraphics

enum Vertex {
    typealias Vertex = _Vertex
    typealias Material = _VertexMaterial
}

protocol _Vertex: IO.Writable {
    init()
}

protocol _VertexMaterial {
    init()
}

extension Vertex {
    enum Materials {}
}

extension Vertex.Materials {
    struct Color {
        init(_ value: SIMD4<Float>) {
            self.value = value
        }

        var value: SIMD4<Float> = .init(0, 0, 0, 1)
    }
}

extension Vertex.Materials.Color {
    init(_ value: CGColor) {
        self.init(.init(value))
    }

    init(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float) {
        self.init(.init(red, green, blue, alpha))
    }
}

extension Vertex.Materials.Color: Vertex.Material {
    init() { self.init(0, 0, 0, 1) }
}

extension D3 {
    struct Vertex<P: Dimension.Precision, M: _VertexMaterial> {
        var position: Measure = .init(0, 0, 0)
        var material: Material = .init()
        var transform: Transform = .init()
    }
}

extension D3.Vertex {
    typealias Precision = P
    typealias Measure = D3.Storage<Precision>
    typealias Material = M
    typealias Transform = D3.Transform<Precision>
}

extension D3.Vertex {
    init(at position: Measure) {
        self.position = position
    }
}

extension D3.Vertex: Vertex.Vertex {}

extension D3.Vertex: IO.Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        withUnsafeBytes(of: self) { bytes in
            destination.copy(from: bytes.baseAddress!, count: bytes.count)
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

    mutating func materialize(with material: Material) {
        self.material = material
    }

    func materialized(with material: Material) -> Self {
        return mapState(self) { $0.materialize(with: material) }
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
