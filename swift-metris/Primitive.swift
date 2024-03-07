// tomocy

import Metal

struct IndexedPrimitive3D {
    var vertices: [Vertex] = []
    var indices: [Index] = []

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

extension IndexedPrimitive3D {
    typealias Vertex = D3.Vertex<Float>
    typealias Index = UInt16
}

extension IndexedPrimitive3D {
    mutating func append(vertices: [Vertex], indices: [Index]) {
        self.vertices += vertices
        self.indices += indices
    }
}

protocol IndexedPrimitive3DAppendable {
    func append(to primitive: inout IndexedPrimitive3D)
}

extension IndexedPrimitive3D: MTLRenderCommandEncodableToIndexedAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLIndexedBuffer, at index: Int) {
        if (vertices.isEmpty) {
            return
        }

        do {
            buffer.data.contents().copyMemory(
                from: vertices,
                byteCount: buffer.data.length
            )
            encoder.setVertexBuffer(buffer.data, offset: 0, index: index)
        }

        do {
            buffer.index.contents().copyMemory(
                from: indices,
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
