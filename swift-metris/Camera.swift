// tomocy

import Metal

struct Camera2D {
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

    private var frameBuffers: MTLSizedBuffers = .init(options: .storageModeShared)
}

extension Camera2D {
    private struct MTLRenderState {
        static var stride: Int { MemoryLayout<Self>.stride }

        var projection: Transform2D = .init()
        var transform: Transform2D = .init()
    }
}

extension Camera2D: MTLFrameRenderCommandEncodableAt {
    mutating func encode(with encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame) {
        encode(
            with: encoder,
            to: frameBuffers.take(
                at: frame.id,
                of: type(of: state).stride,
                with: encoder.device
            ),
            at: index
        )
    }
}


extension Camera2D: MTLRenderCommandEncodableToAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLBuffer, at index: Int) {
        var state = state
        state.transform = state.transform.inversed(rotate: false, scale: false)

        withUnsafeBytes(of: state, { body in
            buffer.contents().copyMemory(
                from: body.baseAddress!,
                byteCount: body.count
            )
            encoder.setVertexBuffer(buffer, offset: 0, index: index)
        })
    }
}

struct Camera3D {
    init(
        projection: Transform3D = .init(),
        transform: Transform3D = .init()
    ) {
        self.projection = projection
        self.transform = transform
    }

    var projection: Transform3D {
        get { state.projection }
        set { state.projection = newValue }
    }
    var transform: Transform3D {
        get { state.transform }
        set { state.transform = newValue }
    }

    var state: MTLRenderState = .init()

    private var frameBuffers: MTLSizedBuffers = .init(options: .storageModeShared)
}

extension Camera3D {
    struct MTLRenderState {
        static var stride: Int { MemoryLayout<Self>.stride }

        var projection: Transform3D = .init()
        var transform: Transform3D = .init()
    }
}

extension Camera3D: MTLFrameRenderCommandEncodableAt {
    mutating func encode(with encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame) {
        encode(
            with: encoder,
            to: frameBuffers.take(
                at: frame.id,
                of: type(of: state).stride,
                with: encoder.device
            ),
            at: index
        )
    }
}

extension Camera3D: MTLRenderCommandEncodableToAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLBuffer, at index: Int) {
        var state = state
        state.transform = state.transform.inversed()

        withUnsafeBytes(of: state, { body in
            buffer.contents().copyMemory(
                from: body.baseAddress!,
                byteCount: body.count
            )
            encoder.setVertexBuffer(buffer, offset: 0, index: index)
        })
    }
}
