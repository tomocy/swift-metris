// tomocy

import simd
import CoreGraphics
import ModelIO
import Metal
import MetalKit

extension D3 {
    class World {
        init(size: CGSize, device: MTLDevice) {
            do {
                let size = SIMD2<Float>.init(size)

                camera = .init(
                    projection: .orthogonal(for: size),
                    transform: .init(
                        translate: .init(size / 2, -size.max() / 10)
                    )
                )
            }

            metris = .init(size: size, device: device)
            metris.start()
        }

        var camera: Camera
        var metris: Metris
    }
}

extension D3.World: MTLFrameRenderCommandEncodable {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        in frame: MTLRenderFrame
    ) {
        camera.encode(with: encoder, at: 0, in: frame)
        metris.encode(with: encoder, at: 1, in: frame)
    }
}

extension D3 {
    class XWorld {
        init(size: CGSize, device: MTLDevice) {
            do {
                let size = SIMD2<Float>.init(size)

                camera = .init(
                    projection: .orthogonal(for: size),
                    transform: .init(
                        translate: .init(size / 2, -size.max() / 10)
                    )
                )
            }

            metris = .init(size: size, device: device)

            do {
                let vertexDescriptor = MDLVertexDescriptor.init()

                var stride = 0

                let attributes = vertexDescriptor.attributes as! [MDLVertexAttribute]

                attributes[0].name = MDLVertexAttributePosition
                attributes[0].format = .float3
                attributes[0].offset = stride
                stride += MemoryLayout<D3.Storage<Float>.Packed>.stride

                attributes[1].name = MDLVertexAttributeNormal
                attributes[1].format = .float3
                attributes[1].offset = stride
                stride += MemoryLayout<D3.Storage<Float>.Packed>.stride

                attributes[2].name = MDLVertexAttributeTextureCoordinate
                attributes[2].format = .float2
                attributes[2].offset = stride
                stride += MemoryLayout<SIMD2<Float>>.stride

                let layouts = vertexDescriptor.layouts as! [MDLVertexBufferLayout]
                layouts[0].stride = stride

                let asset = MDLAsset.init(
                    url: Bundle.main.url(
                        forResource: "Spot", withExtension: "obj", subdirectory: "Spot"
                    )!,
                    vertexDescriptor: vertexDescriptor,
                    bufferAllocator: MTKMeshBufferAllocator.init(device: device)
                )

                asset.loadTextures()

                let raws = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
                let raw = raws.first!

                mesh = try! .init(
                    mesh: raw,
                    device: device
                )

                let submesh = raw.submeshes!.firstObject as! MDLSubmesh
                let loader = MTKTextureLoader.init(device: device)
                texture = try! loader.newTexture(
                    URL: submesh.material!.property(with: .baseColor)!.urlValue!,
                    options: [
                        .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                        .textureStorageMode: MTLStorageMode.private.rawValue,
                        .origin: MTKTextureLoader.Origin.bottomLeft.rawValue
                    ]
                )
            }
        }

        var camera: Camera
        var metris: Metris

        private let mesh: MTKMesh
        private let texture: MTLTexture
        private var n: Int = 0
    }
}

extension D3.XWorld: MTLFrameRenderCommandEncodable {
    private struct XVertex {
        var position: D3.Storage<Float>.Packed
        var normal: D3.Storage<Float>.Packed = .init()
        var textureCoordinate: SIMD2<Float> = .init()
    }

    func encode(
        with encoder: MTLRenderCommandEncoder,
        in frame: MTLRenderFrame
    ) {
        do {
            let near: Float = 1
            let far: Float = 1000

            let aspectRatio: Float = 400 / 800
            let fovX: Float = Angle.init(degree: 120).inRadian()
            let scaleX = 1 / tan(fovX / 2)
            let scaleY = scaleX * aspectRatio

            let projection = D3.Matrix(
                rows: [
                    .init(scaleX, 0, 0, 0),
                    .init(0, scaleY, 0, 0),
                    .init(0, 0, far / (far - near), -(far * near) / (far - near)),
                    .init(0, 0, 1, 0)
                ]
            )

            let model = D3.Matrix(
                rows: [
                    .init(40, 0, 0, 0),
                    .init(0, 40, 0, 0),
                    .init(0, 0, 40, 60),
                    .init(0, 0, 0, 1)
                ]
            )

            let matrix = projection * model

            // n = (n + 2) % 360

            withUnsafeBytes(of: matrix) { bytes in
                let buffer = encoder.device.makeBuffer(length: bytes.count, options: .storageModeShared)!

                buffer.contents().copy(from: bytes.baseAddress!, count: bytes.count)
                encoder.setVertexBuffer(buffer, offset: 0, index: 1)
            }
        }

        do {
            /* let mesh = try! MTKMesh.init(
                mesh: .init(
                    sphereWithExtent: .init(40, 40, 40),
                    segments: .init(16, 16),
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: MTKMeshBufferAllocator.init(device: encoder.device)
                ),
                device: encoder.device
            ) */

            encoder.setFragmentTexture(texture, index: 0)

            mesh.vertexBuffers.enumerated().forEach { i, buffer in
                encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
            }
            mesh.submeshes.enumerated().forEach { i, mesh in
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
