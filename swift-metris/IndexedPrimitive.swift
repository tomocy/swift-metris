// tomocy

import Metal

struct IndexedPrimitive {
    var vertices: [Vertex] = []
    var indices: [UInt16] = []

    var lastIndex: Int { vertices.count - 1 }
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

extension Array {
    var size: Int { MemoryLayout<Element>.stride * count }
}
