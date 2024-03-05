// tomocy

import CoreGraphics
import Metal

protocol World: MTLRenderPipelineDescriable, MTLFrameRenderCommandEncodable {
    var metris: Metris { get }
}

struct World2D: World {
    init(size: CGSize) {
        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            camera = .init(
                projection: .orthogonal(
                    top: halfSize.y, bottom: -halfSize.y,
                    left: -halfSize.x, right: halfSize.x
                ),
                transform: .init(
                    translate: halfSize
                )
            )
        }

        metris = .init(size: size)
        metris.start()
    }

    var camera: Camera2D
    var metris: Metris
}

extension World2D: MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "World2D::shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }
}


extension World2D: MTLFrameRenderCommandEncodable {
    mutating func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        camera.encode(with: encoder, at: 0, in: frame)
        metris.encode(with: encoder, at: 1, in: frame)
    }
}

struct World3D: World {
    init(size: CGSize) {
        metris = .init(size: size)
    }

    var metris: Metris
}

extension World3D: MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "World3D::shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }
}


extension World3D: MTLFrameRenderCommandEncodable {
    mutating func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        let primitive = IndexedPrimitive3D.init(
            vertices: [
                // front
                .init(at: .init(-0.2, 0.2, 0)).colorized(with: .init(1, 0, 0, 1)), // 0
                .init(at: .init(0.2, 0.2, 0)).colorized(with: .init(0, 1, 0, 1)), // 1
                .init(at: .init(0.2, -0.2, 0)).colorized(with: .init(0, 0, 1, 1)), // 2
                .init(at: .init(-0.2, -0.2, 0)).colorized(with: .init(0, 0, 0, 1)), // 3
                // back
                .init(at: .init(0.2, 0.2, 0.2)).colorized(with: .init(1, 0, 0, 1)), // 4
                .init(at: .init(-0.2, 0.2, 0.2)).colorized(with: .init(0, 1, 0, 1)), // 5
                .init(at: .init(-0.2, -0.2, 0.2)).colorized(with: .init(0, 0, 1, 1)), // 6
                .init(at: .init(0.2, -0.2, 0.2)).colorized(with: .init(0, 0, 0, 1)), // 7
            ],
            indices: [
                // front
                0, 1, 2,
                2, 3, 0,
                // back
                4, 5, 6,
                6, 7, 4,
                // left
                1, 4, 7,
                7, 2, 1,
                // right
                5, 0, 3,
                3, 6, 5,
                // top
                1, 0, 5,
                5, 4, 1,
                // back
                7, 6, 3,
                3, 2, 7,
            ]
        )


        primitive.encode(
            with: encoder,
            to: .init(
                data: encoder.device.makeBuffer(
                    length: primitive.vertices.size,
                    options: .storageModeShared
                )!,
                index: encoder.device.makeBuffer(
                    length: primitive.indices.size,
                    options: .storageModeShared
                )!
            ),
            at: 0
        )
    }
}
