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
        init(device: MTLDevice) {
            spot = .init(device: device)
            ground = .init(device: device)
        }

        private let spot: Spot
        private let ground: Ground
        private var n: Int = 0
    }
}

extension D3.XWorld {
    fileprivate struct Vertex {
        var position: D3.Storage<Float>.Packed
        var normal: D3.Storage<Float>.Packed = .init()
        var textureCoordinate: SIMD2<Float> = .init()
    }

    fileprivate struct Lights {
        struct Ambient {
            var intensity: Float = 0
        }

        struct Directional {
            var intensity: Float = 0
            var direction: D3.Storage<Float> = .init(0, 0, 0)
        }

        var ambient: Ambient = .init()
        var directional: Directional = .init()
    }
}

extension D3.XWorld {
    fileprivate struct Spot {
        private let mesh: MTKMesh
        private let texture: MTLTexture
    }
}

extension D3.XWorld.Spot {
    init(device: MTLDevice) {
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
            let rawSubmesh = raw.submeshes!.firstObject as! MDLSubmesh

            mesh = try! .init(
                mesh: raw,
                device: device
            )

            let loader = MTKTextureLoader.init(device: device)
            texture = try! loader.newTexture(
                URL: rawSubmesh.material!.property(with: .baseColor)!.urlValue!,
                options: [
                    .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                    .textureStorageMode: MTLStorageMode.private.rawValue,
                    .origin: MTKTextureLoader.Origin.bottomLeft.rawValue
                ]
            )
        }
    }

    fileprivate func encode(with encoder: MTLRenderCommandEncoder, matrix: D3.Matrix, n: Int) {
        do {
            let model = D3.Transform<Float>.init(
                rotate: .init(0, Angle.init(degree: .init(n % 360)).inRadian(), 0),
                scale: .init(30, 30, 30)
            ).resolve()
            let matrix = matrix * model

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: matrix),
                options: .storageModeShared
            )!
            IO.writable(matrix).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        encoder.setFragmentTexture(texture, index: 0)

        do {
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

extension D3.XWorld {
    fileprivate struct Ground {
        private let mesh: MTKMesh
        private let texture: MTLTexture
    }
}

extension D3.XWorld.Ground {
    init(device: MTLDevice) {
        mesh = try! MTKMesh.init(
            mesh: .init(
                planeWithExtent: .init(100, 100, 100),
                segments: .init(1, 1),
                geometryType: .triangles,
                allocator: MTKMeshBufferAllocator.init(device: device)
            ),
            device: device
        )

        texture = Texture.Sources.Color.load(
            .init(red: 0.1, green: 0.5, blue: 0.2, alpha: 1),
            with: device
        )!.raw
    }
}

extension D3.XWorld.Ground {
    func encode(with encoder: MTLRenderCommandEncoder, matrix: D3.Matrix) {
        do {
            let model = D3.Transform<Float>.init(
                rotate: .init(Angle.init(degree: 90).inRadian(), Angle.init(degree: -90).inRadian(), 0)
            ).resolve()
            let matrix = matrix * model

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: matrix),
                options: .storageModeShared
            )!
            IO.writable(matrix).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        encoder.setFragmentTexture(texture, index: 0)

        do {
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

extension D3.XWorld {
    func shadow(with encoder: MTLRenderCommandEncoder, matrix: D3.Matrix) {
        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout<D3.XWorld.Lights>.stride,
                options: .storageModeShared
            )!

            let lights = D3.XWorld.Lights.init(
                ambient: .init(intensity: 0.5),
                directional: .init(
                    intensity: 1,
                    direction: .init(-1, -1, 1)
                )
            )
            IO.writable(lights).write(to: buffer)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        }

        spot.encode(with: encoder, matrix: matrix, n: n)
        ground.encode(with: encoder, matrix: matrix)
    }
}

extension D3.XWorld {
    func encode(with encoder: MTLRenderCommandEncoder) {
        let projection = ({
            let near: Float = 1
            let far: Float = 1000

            let aspectRatio: Float = 800 / 800
            let fovX: Float = Angle.init(degree: 120).inRadian()
            var scale = SIMD2<Float>.init(1, 1)
            scale.x = 1 / tan(fovX / 2)
            scale.y = scale.x * aspectRatio

            return D3.Matrix(
                rows: [
                    .init(scale.x, 0, 0, 0),
                    .init(0, scale.y, 0, 0),
                    .init(0, 0, far / (far - near), -(far * near) / (far - near)),
                    .init(0, 0, 1, 0)
                ]
            )
        }) ()

        let view = D3.Transform<Float>(
            translate: .init(0, -20, 35)
        ).resolve()

        let matrix = projection * view

        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout<D3.XWorld.Lights>.stride,
                options: .storageModeShared
            )!

            let lights = D3.XWorld.Lights.init(
                ambient: .init(intensity: 0.5),
                directional: .init(
                    intensity: 1,
                    direction: .init(-1, -1, 1)
                )
            )
            IO.writable(lights).write(to: buffer)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        }

        spot.encode(with: encoder, matrix: matrix, n: n)
        ground.encode(with: encoder, matrix: matrix)

        n = (n + 1) % 1024
    }
}
