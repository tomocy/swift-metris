// tomocy

import Metal

struct Camera {
    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        withUnsafeBytes(of: self, { body in
            let buffer = encoder.device.makeBuffer(
                bytes: body.baseAddress!,
                length: body.count,
                options: .storageModeShared
            )!

            encoder.setVertexBuffer(buffer, offset: 0, index: index)
        })
    }

    var projection: Transform2D = Transform2D()
    var transform: Transform2D = Transform2D()
}

