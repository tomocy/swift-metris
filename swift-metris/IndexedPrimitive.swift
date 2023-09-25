// tomocy

import Metal

struct IndexedPrimitive {
    mutating func append(vertices: [Vertex], indices: [UInt16]) {
        self.vertices += vertices
        self.indices += indices
    }

    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        if (vertices.isEmpty) {
            return
        }

        let vertexBuffer = encoder.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Vertex>.stride * vertices.count,
            options: .storageModeShared
        )!
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)

        let indexBuffer = encoder.device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count,
            options: .storageModeShared
        )!
        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }

    var lastIndex: Int {
        vertices.count - 1
    }

    private var vertices: [Vertex] = []
    private var indices: [UInt16] = []
}

