// tomocy

import Metal

struct IndexedPrimitive {
    var verticesSize: Int { MemoryLayout<Vertex>.stride * vertices.count }
    private var vertices: [Vertex] = []

    var indicesSize: Int { MemoryLayout<UInt16>.stride * indices.count }
    var lastIndex: Int { vertices.count - 1 }
    private var indices: [UInt16] = []
}

extension IndexedPrimitive {
    mutating func append(vertices: [Vertex], indices: [UInt16]) {
        self.vertices += vertices
        self.indices += indices
    }
}

protocol IndexedPrimitiveAppendable {
    func append(to primitive: inout IndexedPrimitive)
}

extension IndexedPrimitive: MTLRenderCommandEncodableToIndexedAt {
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
