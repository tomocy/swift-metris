// tomocy

import Metal

struct IndexedPrimitive2D {
    var vertices: [Vertex2D] = []
    var indices: [UInt16] = []

    var lastIndex: Int { vertices.count - 1 }
}

extension IndexedPrimitive2D {
    mutating func append(vertices: [Vertex2D], indices: [UInt16]) {
        self.vertices += vertices
        self.indices += indices
    }
}

protocol IndexedPrimitive2DAppendable {
    func append(to primitive: inout IndexedPrimitive2D)
}

extension IndexedPrimitive2D: MTLRenderCommandEncodableToIndexedAt {
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

struct IndexedPrimitive3D {
    var vertices: [Vertex3D] = []
    var indices: [UInt16] = []

    var lastIndex: Int { vertices.count - 1 }
}

extension IndexedPrimitive3D {
    mutating func append(vertices: [Vertex3D], indices: [UInt16]) {
        self.vertices += vertices
        self.indices += indices
    }
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
