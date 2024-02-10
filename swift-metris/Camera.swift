// tomocy

import Metal

struct Camera {
    var projection: Transform2D = Transform2D()
    var transform: Transform2D = Transform2D()
}

extension Camera: MTLRenderCommandEncodableAt {
    private struct MTLRenderState {
        let projection: Transform2D
        let transform: Transform2D
    }

    func encode(to encoder: MTLRenderCommandEncoder, at index: Int) {
        var state = MTLRenderState(
            projection: projection,
            transform: transform
        )

        withUnsafeBytes(of: &state, { body in
            let buffer = encoder.device.makeBuffer(
                bytes: body.baseAddress!,
                length: body.count,
                options: .storageModeShared
            )!

            encoder.setVertexBuffer(buffer, offset: 0, index: index)
        })
    }
}
