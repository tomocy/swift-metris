// tomocy

import simd
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

        private var n: Int = 0
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
        do {
            let radian = Angle.init(degree: .init(n)).inDegree()
            n = (n + 1) % 360

            let s = sin(radian);
            let c = cos(radian);

            let matrix = simd_float4x4([
                .init(c, 0, -s, 0),
                .init(0, 1, 0, 0),
                .init(s, 0, c, 0),
                .init(0, 0, 0, 1),
            ])

            withUnsafeBytes(of: matrix) { bytes in
                let buffer = encoder.device.makeBuffer(length: bytes.count, options: .storageModeShared)!

                buffer.contents().copy(from: bytes.baseAddress!, count: bytes.count)
                encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            }
        }

        let vertices: [XVertex] = [
            .init(position: .init(-0.2, -0.2, 0)),
            .init(position: .init(0, 0.2, 0)),
            .init(position: .init(0.2, -0.2, 0)),
        ]

        do {
            let buffer = encoder.device.makeBuffer(length: vertices.size, options: .storageModeShared)!

            vertices.write(to: buffer)
            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
