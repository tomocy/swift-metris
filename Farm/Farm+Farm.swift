 // tomocy

import Metal
import MetalKit

enum Farm {}

extension Farm {
    class World {
        init(device: any MTLDevice) {
            time = 0

            camera = Farm.Camera.perspective(
                near: 0.01, far: 100,
                aspectRatio: 1800 / 1200, fovY: .pi / 3,
                transform: .init(
                    translate: .init(0, 0.5, -2)
                )
            )

            lights = .init(
                ambient: .init(
                    color: .init(1, 1, 1),
                    intensity: 0.1
                ),
                directional: .init(
                    color: .init(1, 1, 1),
                    intensity: 0.8,
                    direction: .init(-1, -1, 1)
                ),
                point: .init(
                    color: .init(0.95, 0, 0),
                    intensity: 0.8,
                    transform: .init(
                        translate: .init(-0.5, 1, -0.5)
                    )
                )
            )

            do {
                do {
                    let desc = MDLVertexDescriptor.init()

                    var stride = 0

                    let attrs = desc.attributes as! [MDLVertexAttribute]

                    attrs[0].name = MDLVertexAttributePosition
                    attrs[0].format = .float3
                    attrs[0].offset = stride
                    stride += MemoryLayout<D3.Storage<Float>.Packed>.stride

                    attrs[1].name = MDLVertexAttributeNormal
                    attrs[1].format = .float3
                    attrs[1].offset = stride
                    stride += MemoryLayout<D3.Storage<Float>.Packed>.stride

                    attrs[2].name = MDLVertexAttributeTextureCoordinate
                    attrs[2].format = .float2
                    attrs[2].offset = stride
                    stride += MemoryLayout<SIMD2<Float>>.stride

                    let layouts = desc.layouts as! [MDLVertexBufferLayout]
                    layouts[0].stride = stride

                    let asset = MDLAsset.init(
                        url: Bundle.main.url(
                            forResource: "Spot", withExtension: "obj", subdirectory: "Spot"
                        )!,
                        vertexDescriptor: desc,
                        bufferAllocator: MTKMeshBufferAllocator.init(device: device)
                    )

                    asset.loadTextures()

                    let raws = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
                    let raw = raws.first!
                    let rawSubmesh = raw.submeshes!.firstObject as! MDLSubmesh

                    spots = .init(
                        raw: try! .init(
                            mesh: raw,
                            device: device
                        ),
                        name: "Spots",
                        material: .init(
                            color: try! MTKTextureLoader.init(device: device).newTexture(
                                URL: rawSubmesh.material!.property(with: .baseColor)!.urlValue!,
                                options: [
                                    .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                                    .textureStorageMode: MTLStorageMode.private.rawValue,
                                    .origin: MTKTextureLoader.Origin.bottomLeft.rawValue
                                ]
                            )
                        ),
                        instances: [
                            .init(
                                transform: .init(
                                    translate: .init(-0.8, 0, -0.8)
                                )
                            ),
                            .init(
                                transform: .init(
                                    translate: .init(-0.8, 0, 0.8)
                                )
                            ),
                            .init(
                                transform: .init(
                                    translate: .init(0.8, 0, 0.8)
                                )
                            ),
                            .init(
                                transform: .init(
                                    translate: .init(0.8, 0, -0.8)
                                )
                            )
                        ]
                    )
                }

                monolith = .init(
                    raw: try! .init(
                        mesh: .init(
                            boxWithExtent: .init(0.5, 1.2, 0.2),
                            segments: .init(1, 1, 1),
                            inwardNormals: false,
                            geometryType: .triangles,
                            allocator: MTKMeshBufferAllocator.init(device: device)
                        ),
                        device: device
                    ),
                    name: "Monolith",
                    material: .init(
                        color: Texture.Sources.Color.load(
                            .init(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.95),
                            with: device
                        )!.raw
                    ),
                    instances: [
                        .init(
                            transform: .init(
                                translate: .init(0, 0.6, 0),
                                rotate: .init(0, .pi / 2 / 6, 0)
                            )
                        )
                    ]
                )

                ground = .init(
                    raw: try! .init(
                        mesh: .init(
                            planeWithExtent: .init(4, 0, 4),
                            segments: .init(1, 1),
                            geometryType: .triangles,
                            allocator: MTKMeshBufferAllocator.init(device: device)
                        ),
                        device: device
                    ),
                    name: "Ground",
                    material: .init(
                        color: try! MTKTextureLoader.init(device: device).newTexture(
                            URL: Bundle.main.url(forResource: "Ground", withExtension: "png", subdirectory: "Ground")!,
                            options: [
                                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                                .textureStorageMode: MTLStorageMode.private.rawValue,
                                .origin: MTKTextureLoader.Origin.bottomLeft.rawValue
                            ]
                        )
                    ),
                    instances: [
                        .init(
                            transform: .init()
                        )
                    ]
                )
            }
        }

        var time: Float

        var camera: Camera
        var lights: Lights

        var spots: Mesh
        var monolith: Mesh
        var ground: Mesh
    }
}

extension Farm.World {
    func tick(delta: Float) {
        time += delta

        tickPointLight()
        tickSpots()
    }

    private func tickPointLight() {
        lights.point.color = .init(
            0.95 * max(cos(time), 0),
            0.95 * max(sin(time), 0),
            0.95 * max(cos(time), 0)
        )
    }

    private func tickSpots() {
        for i in 0..<spots.instances.count {
            spots.instances[i].transform.rotate = .init(
                0, time + .pi / 2 * .init(i), 0
            )
        }
    }
}

extension Farm.World: Shader.D3.Shadow.Encodable {
    func encode(with encoder: Shader.D3.Shadow.Encoder) {
        lights.directional.encode(with: encoder.raw)

        do {
            spots.encode(with: encoder.raw)
            ground.encode(with: encoder.raw)
        }
        do {
            monolith.encode(with: encoder.raw)
        }
    }
}

extension Farm.World: Shader.D3.Mesh.Encodable {
    func encode(with encoder: Shader.D3.Mesh.Encoder) {
        camera.encode(with: encoder.raw)
        lights.encode(with: encoder.raw)

        do {
            spots.encode(with: encoder.raw)
            ground.encode(with: encoder.raw)
        }
        do {
            monolith.encode(with: encoder.raw)
        }
    }
}