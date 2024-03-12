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
    mutating func append(vertices: [Vertex], indices: [Index]) {
        self.vertices += vertices
        self.indices += indices
    }
}

extension IndexedPrimitive: MTLRenderCommandEncodableToIndexedAt {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: MTLIndexedBuffer,
        at index: Int
    ) {
        do {
            vertices.write(to: buffer.data.contents())
            encoder.setVertexBuffer(buffer.data, offset: 0, index: index)
        }

        indices.withUnsafeBytes { body in
            buffer.index.contents().copyMemory(
                from: body.baseAddress!,
                byteCount: buffer.index.length
            )

            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indices.count,
                indexType: .uint16,
                indexBuffer: buffer.index,
                indexBufferOffset: 0
            )
        }
    }
}
