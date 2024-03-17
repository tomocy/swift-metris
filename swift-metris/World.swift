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
        }

        var camera: Camera
        var metris: Metris

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
            let projection = camera.projection.resolve()

            let model = D3.Transform<Float>(
                translate: .init(0, 0, 80),
                rotate: .init(0, 0, Angle.init(degree: .init(n)).inRadian())
            ).resolve()

            let matrix = projection * model

            n = (n + 2) % 360

            withUnsafeBytes(of: matrix) { bytes in
                let buffer = encoder.device.makeBuffer(length: bytes.count, options: .storageModeShared)!

                buffer.contents().copy(from: bytes.baseAddress!, count: bytes.count)
                encoder.setVertexBuffer(buffer, offset: 0, index: 1)
            }
        }

        do {
            let mesh = try! MTKMesh.init(
//                mesh: .init(
//                    boxWithExtent: .init(80, 80, 80),
//                    segments: .init(1, 1, 1),
//                    inwardNormals: false,
//                    geometryType: .triangles,
//                    allocator: MTKMeshBufferAllocator.init(device: encoder.device)
//                ),
                mesh: .init(
                    sphereWithExtent: .init(80, 80, 80),
                    segments: .init(16, 16),
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: MTKMeshBufferAllocator.init(device: encoder.device)
                ),
                device: encoder.device
            )

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
