// tomocy

import Metal

struct IndexedPrimitive<V: Vertex.Vertex> {
    var vertices: [Vertex] = []
    var indices: [Index] = []
}

extension IndexedPrimitive {
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
    mutating func append(_ other: Self) {
        append(
            vertices: other.vertices,
            indices: other.indices
        )
    }

    mutating func append(vertices: [Vertex], indices: [Index]) {
        self.vertices += vertices
        self.indices += indices
    }
}

extension IndexedPrimitive: MTLRenderCommandEncodableToIndexed {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int>,
        at index: Int
    ) {
        vertices.write(to: buffer.data.contents())
        indices.write(to: buffer.index.contents())

        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: buffer.index,
            indexBufferOffset: offset.index
        )
    }
}

protocol _IndexedPrimitive {
    associatedtype Vertex: swift_metris.Vertex.Vertex
}

extension IndexedPrimitive {
    typealias Projectable = _IndexedPrimitiveProjectable
    typealias Appendable = _IndexedPrimitiveAppendable
}

protocol _IndexedPrimitiveProjectable<Vertex>: _IndexedPrimitive {
    func project(beside primitive: IndexedPrimitive<Vertex>) -> IndexedPrimitive<Vertex>
}

extension IndexedPrimitive.Projectable {
    func project(beside primitive: IndexedPrimitive<Vertex>? = nil) -> IndexedPrimitive<Vertex> {
        return project(beside: primitive ?? .init())
    }
}

protocol _IndexedPrimitiveAppendable<Vertex>: _IndexedPrimitive {
    func append(to primitive: inout IndexedPrimitive<Vertex>)
}

extension IndexedPrimitive.Appendable where Self: IndexedPrimitive.Projectable {
    func append(to primitive: inout IndexedPrimitive<Vertex>) {
        primitive.append(
            project(beside: primitive)
        )
    }
}
