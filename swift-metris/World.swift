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

    private struct XLights {
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

    func encode(
        with encoder: MTLRenderCommandEncoder,
        in frame: MTLRenderFrame
    ) {
        do {
            let projection = ({
                let near: Float = 1
                let far: Float = 1000

                let aspectRatio: Float = 400 / 800
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

            let view = ({
                let translate = D3.Matrix(
                    rows: [
                        .init(1, 0, 0, 0),
                        .init(0, 1, 0, -20),
                        .init(0, 0, 1, 35),
                        .init(0, 0, 0, 1)
                    ]
                )

                let radian = Angle.init(degree: 0).inRadian()
                let (s, c) = (sin(radian), cos(radian))
                let rotate = D3.Matrix(
                    rows: [
                        .init(c, 0, s, 0),
                        .init(0, 1, 0, 0),
                        .init(-s, 0, c, 0),
                        .init(0, 0, 0, 1)
                    ]
                )

                let scale = D3.Matrix(
                    rows: [
                        .init(1, 0, 0, 0),
                        .init(0, 1, 0, 0),
                        .init(0, 0, 1, 0),
                        .init(0, 0, 0, 1)
                    ]
                )

                return translate * rotate * scale
            }) ()

            let model = ({
                let translate = D3.Matrix(
                    rows: [
                        .init(1, 0, 0, 0),
                        .init(0, 1, 0, /* -20 */ 0),
                        .init(0, 0, 1, /* 35 */ 0),
                        .init(0, 0, 0, 1)
                    ]
                )
                
                let radian = Angle.init(degree: .init(n)).inRadian()
                let (s, c) = (sin(radian), cos(radian))
                let rotate = D3.Matrix(
                    rows: [
                        .init(c, 0, s, 0),
                        .init(0, 1, 0, 0),
                        .init(-s, 0, c, 0),
                        .init(0, 0, 0, 1)
                    ]
                )
                n = (n + 1) % 360

                let scale = D3.Matrix(
                    rows: [
                        .init(40, 0, 0, 0),
                        .init(0, 40, 0, 0),
                        .init(0, 0, 40, 0),
                        .init(0, 0, 0, 1)
                    ]
                )

                return translate * rotate * scale
            }) ()

            let matrix = projection * view * model
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: matrix),
                options: .storageModeShared
            )!
            IO.writable(matrix).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout<XLights>.stride,
                options: .storageModeShared
            )!

            let lights = XLights.init(
                ambient: .init(intensity: 0.5),
                directional: .init(
                    intensity: 1,
                    direction: .init(-1, -1, 1)
                )
            )
            IO.writable(lights).write(to: buffer)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        }

        do {
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
