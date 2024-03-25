// tomocy

import Metal

enum Shader {}

extension Shader {
    typealias RenderContext = _ShaderRenderContext
}

protocol _ShaderRenderContext {
    var encoder: any MTLRenderCommandEncoder { get }
    var buffers: Shader.Buffers.Framed { get }
}

extension Shader.D3 {
    struct Shader {
        let device: any MTLDevice
        var commandQueue: MTLCommandQueue
        var buffers: App.Shader.Buffers
        var framePool: App.Shader.SemaphoricPool<Framed>
    }
}

extension Shader.D3.Shader {
    init(device: any MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        buffers = .init(device: device)

        // This is the frame pool that achieves "Triple Buffering",
        // or more precisely, "Triple Framing".
        framePool = .init(size: 3) { [buffers] i in
            return .init(
                device: device,
                frame: .init(id: i),
                buffers: buffers
            )
        }
    }
}

extension Shader.D3.Shader {
    mutating func acquire() -> Framed {
        return framePool.acquire()
    }

    mutating func release() {
        framePool.release()
    }
}

extension Shader.D3.Shader {
    struct Framed {
        let frame: Shader.Frame

        var shadow: Shader.D3.Shadow
        var mesh: Shader.D3.Mesh
    }
}

extension Shader.D3.Shader.Framed {
    init(device: some MTLDevice, frame: Shader.Frame, buffers: Shader.Buffers) {
        self.frame = frame

        shadow = .init(
            device: device,
            buffers: .init(frame: frame, buffers: buffers)
        )

        mesh = .init(
            device: device,
            buffers: .init(frame: frame, buffers: buffers)
        )
    }
}
