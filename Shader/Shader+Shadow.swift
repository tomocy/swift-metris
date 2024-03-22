// tomocy

import Metal

extension Shader.D3 {
    struct Shadow {
        var target: any MTLTexture
        var pipelineStates: PipelineStates
    }
}

extension Shader.D3.Shadow {
    func encode(_ target: Encodable, to buffer: MTLCommandBuffer) {
        let encoder = buffer.makeRenderCommandEncoder(
            descriptor: describe()
        )!
        defer { encoder.endEncoding() }

        encoder.setCullMode(.back)

        encoder.setRenderPipelineState(pipelineStates.render)
        encoder.setDepthStencilState(pipelineStates.depthStencil)

        var buffers: Buffers? = nil
        target.allocate(&buffers, with: encoder.device)

        target.encode(with: encoder, to: buffers!)
    }

    private func describe() -> MTLRenderPassDescriptor {
        let desc = MTLRenderPassDescriptor.init()

        let attach = desc.depthAttachment!

        attach.texture = target

        attach.loadAction = .clear
        attach.clearDepth = 1

        attach.storeAction = .store

        return desc
    }
}

extension Shader.D3.Shadow {
    struct PipelineStates {
        var render: any MTLRenderPipelineState
        var depthStencil: any MTLDepthStencilState
    }
}

extension Shader.D3.Shadow {
    struct Buffers {
        var vertices: any MTLBuffer
        var indices: any MTLBuffer
        var aspect: any MTLBuffer
        var models: any MTLBuffer
    }
}

extension Shader.D3.Shadow {
    typealias Encodable = _ShaderD3ShadowEncodable
}

protocol _ShaderD3ShadowEncodable {
    func allocate(_ buffers: inout Shader.D3.Shadow.Buffers?, with device: any MTLDevice)
    func encode(with encoder: any MTLRenderCommandEncoder, to buffers: Shader.D3.Shadow.Buffers)
}
