// tomocy

import MetalKit

extension Engine.D3 {
    struct Mesh {
        var raw: MTKMesh
        var name: String
        var material: Engine.Material

        var instances: [Instance]
    }
}

extension Engine.D3.Mesh {
    struct Instance {
        var transform: Engine.D3.Transform
    }
}

extension Engine.D3.Mesh {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        encoder.setFragmentTexture(material.color, index: 1)

        do {
            let models: [Shader.D3.Model] = instances.map {
                .init(transform: $0.transform.resolve())
            }

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout<Shader.D3.Model>.stride * models.count,
                options: .storageModeShared
            )!
            buffer.label = "\(name): Models: {Count: \(models.count)}"

            IO.writable(models).write(to: buffer)
            encoder.setVertexBuffer(buffer, offset: 0, index: 2)
        }

        do {
            raw.vertexBuffers.forEach { buffer in
                buffer.buffer.label = "\(name): Vertex: {Offset: \(buffer.offset)}"
                encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: 0)
            }

            raw.submeshes.forEach { mesh in
                mesh.indexBuffer.buffer.label = "\(name): Index: {Offset: \(mesh.indexBuffer.offset)}"
                encoder.drawIndexedPrimitives(
                    type: mesh.primitiveType,
                    indexCount: mesh.indexCount,
                    indexType: mesh.indexType,
                    indexBuffer: mesh.indexBuffer.buffer,
                    indexBufferOffset: mesh.indexBuffer.offset,
                    instanceCount: instances.count
                )
            }
        }
    }
}
