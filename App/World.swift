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
            spots = .init(device: device)
            monolith = .init(device: device)
            ground = .init(device: device)
        }

        private var time: Float = 0
        private let spots: Spots
        private let monolith: Monolith
        private let ground: Ground
    }
}

extension D3.XWorld {
    func tick(delta: Float) {
        time += delta
    }
}

extension D3.XWorld: App.Shader.D3.Shadow.Encodable {
    func encode(with encoder: Shader.D3.Shadow.Encoder) {
        let light = ({
            let projection = D3.Transform<Float>.orthogonal(
                top: 1.5, bottom: -1.5,
                left: -1.5, right: 1.5,
                near: 0, far: 10
            ).resolve()

            let view = D3.Transform<Float>.look(
                from: .init(1, 1, -1),
                to: .init(0, 0, 0),
                up: .init(0, 1, 0)
            ).inverse

            return Shader.D3.Aspect.init(
                projection: projection,
                view: view
            )
        }) ()

        spots.encode(with: encoder.raw, from: light, time: time)
        ground.encode(with: encoder.raw, from: light)
        monolith.encode(with: encoder.raw, from: light)
    }
}

extension D3.XWorld: App.Shader.D3.Mesh.Encodable {
    func encode(with encoder: Shader.D3.Mesh.Encoder) {
        do {
            let ambient = Shader.D3.Light.init(
                color: .init(1, 1, 1),
                intensity: 0.1,
                aspect: .init(
                    projection: .init(1),
                    view: .init(1)
                )
            )

            let directional = ({
                let projection = D3.Transform<Float>.orthogonal(
                    top: 1.5, bottom: -1.5,
                    left: -1.5, right: 1.5,
                    near: 0, far: 10
                ).resolve()

                let view = D3.Transform<Float>.look(
                    from: .init(1, 1, -1),
                    to: .init(0, 0, 0),
                    up: .init(0, 1, 0)
                ).inverse

                return Shader.D3.Light.init(
                    color: .init(1, 1, 1),
                    intensity: 1,
                    aspect: .init(
                        projection: projection,
                        view: view
                    )
                )
            }) ()

            let point = ({
                let color = SIMD3<Float>.init(
                    0.95 * max(cos(time), 0),
                    0.95 * max(sin(time), 0),
                    0.95 * max(cos(time), 0)
                )

                return Shader.D3.Light.init(
                    color: color,
                    intensity: 0.8,
                    aspect: .init(
                        projection: .identity,
                        view: D3.Transform<Float>.look(
                            from: .init(-0.5, 1, -0.5),
                            to: .init(0, 0, 0),
                            up: .init(0, 1, 0)
                        )
                    )
                )
            }) ()

            let lights = Shader.D3.Lights.init(
                ambient: ambient,
                directional: directional,
                point: point
            )

            lights.encode(with: encoder.raw)
        }


        let view = ({
            let projection = ({
                let near: Float = 0.01
                let far: Float = 100

                let scale = ({
                    let aspectRatio: Float = 1800 / 1200
                    let fovY: Float = .pi / 3

                    var scale = SIMD2<Float>.init(1, 1)
                    scale.y = 1 / tan(fovY / 2)
                    scale.x = scale.y / aspectRatio // 1 / w = (1 / h) * (h / w)

                    return scale
                }) ()

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
                translate: .init(0, 0.5, -2)
            ).inversed(
                rotate: false, scale: false
            ).resolve()

            return Shader.D3.Aspect.init(
                projection: projection,
                view: view
            )
        }) ()

        spots.encode(with: encoder.raw, from: view, time: time)
        ground.encode(with: encoder.raw, from: view)
        monolith.encode(with: encoder.raw, from: view)
    }
}

extension Shader.D3.Lights {
    func encode(with encoder: MTLRenderCommandEncoder) {
        let buffer = encoder.device.makeBuffer(
            length: MemoryLayout<Self>.stride,
            options: .storageModeShared
        )!
        buffer.label = "Lights"

        IO.writable(self).write(to: buffer)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
    }
}

extension D3.XWorld {
    fileprivate struct Spots {
        private let mesh: MTKMesh
        private let texture: MTLTexture
    }
}

extension D3.XWorld.Spots {
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

    fileprivate func encode(with encoder: MTLRenderCommandEncoder, from aspect: Shader.D3.Aspect, time: Float) {
        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: aspect),
                options: .storageModeShared
            )!
            buffer.label = "Spot: Aspect"

            IO.writable(aspect).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        var models: [Shader.D3.Model] = []

        do {
            let radius: Float = 0.8

            models.append(
                .init(
                    transform: D3.Transform<Float>.init(
                        translate: .init(radius, 0, -radius),
                        rotate: .init(0, time + .pi / 2 * 0, 0)
                    ).resolve()
                )
            )

            models.append(
                .init(
                    transform: D3.Transform<Float>.init(
                        translate: .init(radius, 0, radius),
                        rotate: .init(0, time + .pi / 2 * 1, 0)
                    ).resolve()
                )
            )

            models.append(
                .init(
                    transform: D3.Transform<Float>.init(
                        translate: .init(-radius, 0, radius),
                        rotate: .init(0, time + .pi / 2 * 2, 0)
                    ).resolve()
                )
            )

            models.append(
                .init(
                    transform: D3.Transform<Float>.init(
                        translate: .init(-radius, 0, -radius),
                        rotate: .init(0, time + .pi / 2 * 3, 0)
                    ).resolve()
                )
            )

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout<Shader.D3.Model>.stride * models.count,
                options: .storageModeShared
            )!
            buffer.label = "Spot: Models"

            IO.writable(models).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 2)
        }

        encoder.setFragmentTexture(texture, index: 1)

        do {
            mesh.vertexBuffers.enumerated().forEach { i, buffer in
                buffer.buffer.label = "Spot: Vertex: \(i)"
                encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
            }

            mesh.submeshes.enumerated().forEach { i, mesh in
                mesh.indexBuffer.buffer.label = "Spot: Index: \(i)"

                encoder.drawIndexedPrimitives(
                    type: mesh.primitiveType,
                    indexCount: mesh.indexCount,
                    indexType: mesh.indexType,
                    indexBuffer: mesh.indexBuffer.buffer,
                    indexBufferOffset: mesh.indexBuffer.offset,
                    instanceCount: models.count
                )
            }
        }
    }
}

extension D3.XWorld {
    fileprivate struct Monolith {
        private let mesh: MTKMesh
        private let texture: MTLTexture
    }
}

extension D3.XWorld.Monolith {
    init(device: MTLDevice) {
        mesh = try! MTKMesh.init(
            mesh: .init(
                boxWithExtent: .init(0.5, 1.2, 0.2),
                segments: .init(1, 1, 1),
                inwardNormals: false,
                geometryType: .triangles,
                allocator: MTKMeshBufferAllocator.init(device: device)
            ),
            device: device
        )

        texture = Texture.Sources.Color.load(
            .init(red: 0.075, green: 0.075, blue: 0.075, alpha: 0.75),
            with: device
        )!.raw
    }
}

extension D3.XWorld.Monolith {
    func encode(with encoder: MTLRenderCommandEncoder, from aspect: Shader.D3.Aspect) {
        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: aspect),
                options: .storageModeShared
            )!
            buffer.label = "Monolith: Aspect"

            IO.writable(aspect).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        do {
            let model = Shader.D3.Model.init(
                transform: D3.Transform<Float>.init(
                    translate: .init(0, 0.6, 0),
                    rotate: .init(0, .pi / 2 / 6, 0)
                ).resolve()
            )

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: model),
                options: .storageModeShared
            )!
            buffer.label = "Monolith: Model"

            IO.writable(model).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 2)
        }

        encoder.setFragmentTexture(texture, index: 1)

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
                planeWithExtent: .init(4, 0, 4),
                segments: .init(1, 1),
                geometryType: .triangles,
                allocator: MTKMeshBufferAllocator.init(device: device)
            ),
            device: device
        )

        do {
            let loader = MTKTextureLoader.init(device: device)

            texture = try! loader.newTexture(
                URL: Bundle.main.url(forResource: "Ground", withExtension: "png", subdirectory: "Ground")!,
                options: [
                    .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                    .textureStorageMode: MTLStorageMode.private.rawValue,
                    .origin: MTKTextureLoader.Origin.bottomLeft.rawValue
                ]
            )
        }
    }
}

extension D3.XWorld.Ground {
    func encode(with encoder: MTLRenderCommandEncoder, from aspect: Shader.D3.Aspect) {
        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: aspect),
                options: .storageModeShared
            )!
            buffer.label = "Ground: Aspect"

            IO.writable(aspect).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        do {
            let model = Shader.D3.Model.init(
                transform: D3.Transform<Float>.init().resolve()
            )

            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: model),
                options: .storageModeShared
            )!
            buffer.label = "Ground: Models"

            IO.writable(model).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 2)
        }

        encoder.setFragmentTexture(texture, index: 1)

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
