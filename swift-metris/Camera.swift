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

    private var frameBuffers: [Int: MTLBuffer] = [:]
}

extension Camera: MTLRenderCommandEncodableWithAt {
    func encode(to encoder: MTLRenderCommandEncoder, with buffer: MTLBuffer, at index: Int) {
        withUnsafeBytes(of: state, { body in
            buffer.contents().copyMemory(
                from: body.baseAddress!,
                byteCount: body.count
            )
            encoder.setVertexBuffer(buffer, offset: 0, index: index)
        })
    }
}

extension Camera: MTLFrameRenderCommandEncodableAt {
    private struct MTLRenderState {
        static var stride: Int { MemoryLayout<Self>.stride }

        var projection: Transform2D = .init()
        var transform: Transform2D = .init()
    }

    mutating func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame) {
        if !frameBuffers.keys.contains(frame.id) {
            frameBuffers[frame.id] = encoder.device.makeBuffer(
                length: type(of: state).stride,
                options: .storageModeShared
            )
        }

        encode(
            to: encoder,
            with: frameBuffers[frame.id]!, at: index
        )
    }
}
