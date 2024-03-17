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
        var position: D3.Storage<Float>.Packed
        var normal: D3.Storage<Float>.Packed = .init()
        var textureCoordinate: SIMD2<Float> = .init()
    }

    func encode(
        with encoder: MTLRenderCommandEncoder,
        in frame: MTLRenderFrame
    ) {
        do {
            let projection = camera.projection.resolve()
            let model = D3.Transform<Float>(
                translate: .init(0, 0, 0),
                rotate: .init(0, 0, Angle.init(degree: .init(n)).inRadian())
            ).resolve()
            let matrix = projection * model

            n = (n + 2) % 360

            withUnsafeBytes(of: matrix) { bytes in
                let buffer = encoder.device.makeBuffer(length: bytes.count, options: .storageModeShared)!

                buffer.contents().copy(from: bytes.baseAddress!, count: bytes.count)
                encoder.setVertexBuffer(buffer, offset: 0, index: 1)
            }
        }

        do {
            let halfSize: Float = 40
            let vertices: [XVertex] = [
                .init(position: .init(-halfSize, halfSize, 0)),
                .init(position: .init(halfSize, halfSize, 0)),
                .init(position: .init(halfSize, -halfSize, 0)),
                .init(position: .init(-halfSize, -halfSize, 0)),
            ]

            let buffer = encoder.device.makeBuffer(length: vertices.size, options: .storageModeShared)!
            vertices.write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        }

        do {
            let indices: [UInt16] = [
                0, 1, 2,
                2, 3, 0,
            ]

            let buffer = encoder.device.makeBuffer(length: indices.size, options: .storageModeShared)!
            indices.write(to: buffer)

            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indices.count,
                indexType: .uint16,
                indexBuffer: buffer,
                indexBufferOffset: 0
            )
        }
    }
}
