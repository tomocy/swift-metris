// tomocy

import Metal

extension D3 {
    struct Camera {
        init(
            projection: Transform = .init(),
            transform: Transform = .init()
        ) {
            self.projection = projection
            self.transform = transform
        }

        var projection: Transform {
            get { state.projection }
            set { state.projection = newValue }
        }
        var transform: Transform {
            get { state.transform }
            set { state.transform = newValue }
        }

        var state: MTLRenderState = .init()

        private var frameBuffers: MTLSizedBuffers = .init(options: .storageModeShared)
    }
}

extension D3.Camera {
    typealias Transform = D3.Transform<Float>
}

extension D3.Camera {
    struct MTLRenderState {
        static var stride: Int { MemoryLayout<Self>.stride }

        var projection: Transform = .init()
        var transform: Transform = .init()
    }
}

extension D3.Camera: MTLFrameRenderCommandEncodableAt {
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

extension D3.Camera: MTLRenderCommandEncodableToAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLBuffer, at index: Int) {
        var state = state

        // Camera should move invertedly to translate itself in the same direction as others.
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
        projection: Transform = .init(),
        transform: Transform = .init()
    ) {
        self.projection = projection
        self.transform = transform
    }

    var projection: Transform {
        get { state.projection }
        set { state.projection = newValue }
    }
    var transform: Transform {
        get { state.transform }
        set { state.transform = newValue }
    }

    var state: MTLRenderState = .init()

    private var frameBuffers: MTLSizedBuffers = .init(options: .storageModeShared)
}

extension Camera3D {
    typealias Transform = D3.Transform<Float>
}

extension Camera3D {
    struct MTLRenderState {
        static var stride: Int { MemoryLayout<Self>.stride }

        var projection: Transform = .init()
        var transform: Transform = .init()
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

        // Camera should move invertedly to translate itself in the same direction as others.
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
