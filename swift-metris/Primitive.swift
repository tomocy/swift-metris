// tomocy

import Metal

extension D3 {
    struct IndexedPrimitive<Precision: DimensionalPrecision> {
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
}

extension D3.IndexedPrimitive {
    typealias Vertex = D3.Vertex<Precision>
    typealias Index = UInt16
}

extension D3.IndexedPrimitive {
    mutating func append(vertices: [Vertex], indices: [Index]) {
        self.vertices += vertices
        self.indices += indices
    }
}

protocol IndexedPrimitive3DAppendable {
    associatedtype Precision: DimensionalPrecision
    typealias Primitive = D3.IndexedPrimitive<Precision>

    func append(to primitive: inout Primitive)
}

extension D3.IndexedPrimitive: MTLRenderCommandEncodableToIndexedAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLIndexedBuffer, at index: Int) {
        if (vertices.isEmpty) {
            return
        }

        vertices.withUnsafeBytes({ body in
            buffer.data.contents().copyMemory(
                from: body.baseAddress!,
                byteCount: buffer.data.length
            )

            encoder.setVertexBuffer(buffer.data, offset: 0, index: index)
        })

        indices.withUnsafeBytes({ body in
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
        })
    }
}
