// tomocy

import Metal

extension Shader.D3 {
    struct Mesh {
        var pipelineStates: PipelineStates
    }
}

extension Shader.D3.Mesh {
    func encode(
        _ target: Encodable,
        to buffer: MTLCommandBuffer,
        as descriptor: MTLRenderPassDescriptor,
        shadow: any MTLTexture
    ) {
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        defer { encoder.endEncoding() }

        encoder.setCullMode(.back)

        encoder.setRenderPipelineState(pipelineStates.render)
        encoder.setDepthStencilState(pipelineStates.depthStencil)

        encoder.setFragmentTexture(shadow, index: 0)

        var buffers: Buffers? = nil
        target.allocate(&buffers, with: encoder.device)

        target.encode(with: encoder, to: buffers!)
    }
}

extension Shader.D3.Mesh {
    struct PipelineStates {
        var render: any MTLRenderPipelineState
        var depthStencil: any MTLDepthStencilState
    }
}

extension Shader.D3.Mesh {
    struct Buffers {
        var vertices: any MTLBuffer
        var indices: any MTLBuffer
        var aspect: any MTLBuffer
        var models: any MTLBuffer
        var lights: any MTLBuffer
    }
}

extension Shader.D3.Mesh {
    typealias Encodable = _ShaderD3MeshEncodable
}

protocol _ShaderD3MeshEncodable {
    func allocate(_ buffers: inout Shader.D3.Mesh.Buffers?, with device: any MTLDevice)
    func encode(with encoder: any MTLRenderCommandEncoder, to buffers: Shader.D3.Mesh.Buffers)
}
