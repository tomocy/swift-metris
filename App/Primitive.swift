// tomocy

import Metal

enum Primitive {
    typealias Primitive = _Primitive
}

protocol _Primitive {
    associatedtype Vertex: App.Vertex.Vertex
}

struct IndexedPrimitive<V: Vertex.Vertex> {
    var vertices: [Vertex] = []
    var indices: [Index] = []
}

extension IndexedPrimitive: Primitive.Primitive {
    typealias Vertex = V
    typealias Index = UInt16
}

extension IndexedPrimitive {
    var lastEndIndex: Index? {
        let count = vertices.count
        return count >= 1
            ? .init(count - 1)
            : nil
    }

    var nextStartIndex: Index {
        if let end = lastEndIndex {
            return end + 1
        }

        return 0
    }
}

extension IndexedPrimitive {
    mutating func shift(beside other: Self) {
        indices = indices.map { $0 + other.nextStartIndex }
    }

    func shifted(beside other: Self) -> Self {
        return mapState(self) { $0.shift(beside: other) }
    }
}

extension IndexedPrimitive {
    mutating func append(_ other: Self) {
        append(
            vertices: other.vertices,
            indices: other.indices
        )
    }

    func appent(_ other: Self) -> Self {
        return mapState(self) { $0.append(other) }
    }

    mutating func append(vertices: [Vertex], indices: [Index]) {
        self.vertices += vertices
        self.indices += indices
    }

    func appent(vertices: [Vertex], indices: [Index]) -> Self {
        return mapState(self) {
            $0.append(vertices: vertices, indices: indices)
        }
    }
}

extension IndexedPrimitive: MTLRenderCommandEncodableToIndexed {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int>
    ) {
        vertices.write(to: buffer.data, by: offset.data)
        indices.write(to: buffer.index, by: offset.index)

        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: buffer.index,
            indexBufferOffset: offset.index
        )
    }
}

extension IndexedPrimitive {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int> = .zero,
        beside primitive: Self
    ) {
        let target = shifted(beside: primitive)

        let offset = offset + Indexed(
            data: primitive.vertices.size,
            index: primitive.indices.size
        )

        target.vertices.write(to: buffer.data, by: offset.data)
        target.indices.write(to: buffer.index, by: offset.index)

        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: target.indices.count,
            indexType: .uint16,
            indexBuffer: buffer.index,
            indexBufferOffset: offset.index
        )
    }
}

extension IndexedPrimitive {
    typealias Projectable = _IndexedPrimitiveProjectable
    typealias Appendable = _IndexedPrimitiveAppendable
}

protocol _IndexedPrimitiveProjectable<Vertex>: Primitive.Primitive {
    func project(beside primitive: IndexedPrimitive<Vertex>) -> IndexedPrimitive<Vertex>
}

extension IndexedPrimitive.Projectable {
    func project(beside primitive: IndexedPrimitive<Vertex>? = nil) -> IndexedPrimitive<Vertex> {
        return project(beside: primitive ?? .init())
    }
}

protocol _IndexedPrimitiveAppendable<Vertex>: Primitive.Primitive {
    func append(to primitive: inout IndexedPrimitive<Vertex>)
}

extension IndexedPrimitive.Appendable where Self: IndexedPrimitive.Projectable {
    func append(to primitive: inout IndexedPrimitive<Vertex>) {
        primitive.append(
            project(beside: primitive)
        )
    }
}
