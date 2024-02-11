// tomocy

import Metal

struct Camera {
    init(
        projection: Transform2D = .init(),
        transform: Transform2D = .init()
    ) {
        self.projection = projection
        self.transform = transform
    }

    var projection: Transform2D {
        get { state.projection }
        set { state.projection = newValue }
    }
    var transform: Transform2D {
        get { state.transform }
        set { state.transform = newValue }
    }

    private var state: MTLRenderState = .init()
}

extension Camera: MTLFrameRenderCommandEncodableAt {
    private struct MTLRenderState {
        var projection: Transform2D = .init()
        var transform: Transform2D = .init()
    }

    func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame) {
        withUnsafeBytes(of: state, { body in
            let buffer = encoder.device.makeBuffer(
                bytes: body.baseAddress!,
                length: body.count,
                options: .storageModeShared
            )!

            encoder.setVertexBuffer(buffer, offset: 0, index: index)
        })
    }
}
