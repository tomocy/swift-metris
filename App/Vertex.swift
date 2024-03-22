// tomocy

import CoreGraphics

enum Vertex {
    typealias Vertex = _Vertex
}

protocol _Vertex: DefaultInitializable, IO.Writable {}

extension D3 {
    struct Vertex<P: Dimension.Precision> {
        var position: Measure = .init(0, 0, 0)
        var material: Material = .init()
        var transform: Transform = .init()
    }
}

extension D3.Vertex {
    typealias Precision = P
    typealias Measure = D3.Storage<Precision>
    typealias Material = App.Material.Reference
    typealias Transform = D3.Transform<Precision>
}

extension D3.Vertex: Vertex.Vertex {}

extension D3.Vertex: IO.Writable {}

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
