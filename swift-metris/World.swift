// tomocy

import CoreGraphics
import Metal

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
    }
}

extension D3.XWorld: MTLFrameRenderCommandEncodable {
    private struct XVertex {
        var position: D3.Storage<Float>
    }

    func encode(
        with encoder: MTLRenderCommandEncoder,
        in frame: MTLRenderFrame
    ) {
        let vertices: [XVertex] = [
            .init(position: .init(-0.2, -0.2, 0)),
            .init(position: .init(0, 0.2, 0)),
            .init(position: .init(0.2, -0.2, 0)),
        ]


        let buffer = encoder.device.makeBuffer(length: vertices.size, options: .storageModeShared)!
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        vertices.write(to: buffer)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
