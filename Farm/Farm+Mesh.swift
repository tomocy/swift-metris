// tomocy

import MetalKit

extension Farm {
    struct Mesh {
        var name: String
        var raw: MTKMesh
        var material: Material
        var transform: D3.Transform<Float>
    }
}

extension Farm.Mesh {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        encoder.setFragmentTexture(material.color, index: 1)

        do {
            let models: [Shader.D3.Model] = [
                .init(transform: transform.resolve())
            ]

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout<Shader.D3.Model>.stride * models.count,
                options: .storageModeShared
            )!
            buffer.label = "\(name): Models"

            IO.writable(models).write(to: buffer)
            encoder.setVertexBuffer(buffer, offset: 0, index: 2)
        }

        do {
            raw.vertexBuffers.forEach { buffer in
                encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: 0)
            }

            raw.submeshes.forEach { mesh in
                encoder.drawIndexedPrimitives(
                    type: mesh.primitiveType,
                    indexCount: mesh.indexCount,
                    indexType: mesh.indexType,
                    indexBuffer: mesh.indexBuffer.buffer,
                    indexBufferOffset: mesh.indexBuffer.offset
                )
            }
        }
    }
}
