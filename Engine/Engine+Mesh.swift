// tomocy

import Foundation
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
    init(
        url: URL,
        device: any MTLDevice,
        allocator: any MDLMeshBufferAllocator,
        colorTextureOptions: [MTKTextureLoader.Option : Any]? = nil,
        instances: [Instance]
    ) {
        let asset = MDLAsset.init(
            url: url,
            vertexDescriptor: Shader.D3.Mesh.PipelineStates.describe(),
            bufferAllocator: allocator
        )

        asset.loadTextures()

        let raws = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        let raw = raws.first!
        let rawSubmesh = raw.submeshes!.firstObject as! MDLSubmesh

        self.init(
            raw: try! .init(
                mesh: raw,
                device: device
            ),
            name: "Spots",
            material: .init(
                color: try! MTKTextureLoader.init(device: device).newTexture(
                    URL: rawSubmesh.material!.property(with: .baseColor)!.urlValue!,
                    options: colorTextureOptions
                )
            ),
            instances: instances
        )
    }
}

extension Engine.D3.Mesh {
    func encode(in context: some Shader.RenderContext) {
        context.encoder.setFragmentTexture(material.color, index: 1)

        do {
            let models: [Shader.D3.Model] = instances.map {
                .init(transform: $0.transform.resolve())
            }

            models.encode(in: context, key: "\(name)/Models?Count=\(models.count)")
        }

        do {
            raw.vertexBuffers.forEach { buffer in
                buffer.buffer.label = "\(name)/Vertex?Offset=\(buffer.offset)"

                context.encoder.setVertexBuffer(
                    buffer.buffer,
                    offset: buffer.offset,
                    index: 0
                )
            }

            raw.submeshes.forEach { mesh in
                mesh.indexBuffer.buffer.label = "\(name)/Index?Offset=\(mesh.indexBuffer.offset)"

                context.encoder.drawIndexedPrimitives(
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
