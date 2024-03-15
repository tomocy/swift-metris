// tomocy

import CoreGraphics
import Metal

extension D3 {
    class World {
        init(with device: MTLDevice, for size: CGSize) {
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

            metris = .init(with: device, for: size)
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
