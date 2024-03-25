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
        var commandQueue: MTLCommandQueue
        var buffers: App.Shader.Buffers

        var shadow: Shadow
        var mesh: Mesh
    }
}

extension Shader.D3.Shader {
    init(device: any MTLDevice) {
        commandQueue = device.makeCommandQueue()!
        buffers = .init(device: device)

        shadow = .init(
            device: device,
            buffers: .init(frame: 0, buffers: buffers)
        )
        mesh = .init(
            device: device,
            buffers: .init(frame: 0, buffers: buffers)
        )
    }
}
