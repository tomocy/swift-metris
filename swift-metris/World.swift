// tomocy

import CoreGraphics
import Metal

protocol World: MTLRenderPipelineDescriable, MTLFrameRenderCommandEncodableAs {
    var metris: Metris { get }
}

extension D3 {
    class World {
        init(size: CGSize, device: MTLDevice) {
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

            metris = .init(size: size, device: device)
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

extension D3.World: MTLFrameRenderCommandEncodableAs {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        as descriptor: MTLRenderPipelineDescriptor,
        in frame: MTLRenderFrame
    ) {
        camera.encode(with: encoder, at: 0, in: frame)
        metris.encode(with: encoder, as: descriptor, at: 1, in: frame)
    }
}
