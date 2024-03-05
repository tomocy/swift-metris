// tomocy

import CoreGraphics
import Metal

struct World2D {
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

        metris = Metris(size: size)
        metris.start()
    }

    var camera: Camera2D
    var metris: Metris
}

extension World2D {
    static func describe(to descriptor: MTLRenderPipelineDescriptor, with device: MTLDevice) {
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