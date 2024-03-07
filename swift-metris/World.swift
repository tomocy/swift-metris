// tomocy

import CoreGraphics
import Metal

protocol World: MTLRenderPipelineDescriable, MTLFrameRenderCommandEncodable {
    var metris: Metris { get }
}

extension D3 {
    class World {
        init(size: CGSize) {
            do {
                let halfSize = SIMD2<Float>.init(size) / 2
                let halfDepth = halfSize.max()
                camera = .init(
                    projection: .orthogonal(
                        top: halfSize.y, bottom: -halfSize.y,
                        left: -halfSize.x, right: halfSize.x,
                        near: -halfDepth, far: halfDepth
                    ),
                    transform: .init(
                        translate: .init(halfSize, 0)
                    )
                )
            }

            metris = .init(size: size)
            metris.start()
        }

        var camera: Camera
        var metris: Metris
    }
}

extension D3.World: World {}

extension D3.World: MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "D3::shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }
}

extension D3.World: MTLFrameRenderCommandEncodable {
    func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        camera.encode(with: encoder, at: 0, in: frame)
        metris.encode(with: encoder, at: 1, in: frame)
    }
}

class World3D: World {
    init(size: CGSize) {
        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            let halfDepth = halfSize.max()
            camera = .init(
                projection: .orthogonal(
                    top: halfSize.y, bottom: -halfSize.y,
                    left: -halfSize.x, right: halfSize.x,
                    near: -halfDepth, far: halfDepth
                ),
                transform: .init(
                    translate: .init(halfSize, 0)
                )
            )
        }

        metris = .init(size: size)
        metris.start()
    }

    var camera: D3.Camera
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
    func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        camera.encode(with: encoder, at: 0, in: frame)
        metris.encode(with: encoder, at: 1, in: frame)
    }
}
