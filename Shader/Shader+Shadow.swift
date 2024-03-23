// tomocy

import Metal

extension Shader.D3 {
    struct Shadow {
        var target: any MTLTexture
        var pipelineStates: PipelineStates
    }
}

extension Shader.D3.Shadow {
    init(device: any MTLDevice) {
        target = Self.makeTarget(with: device)!

        pipelineStates = .init(
            render: try! PipelineStates.make(with: device),
            depthStencil: PipelineStates.make(with: device)!
        )
    }
}

extension Shader.D3.Shadow {
    private static func makeTarget(with device: any MTLDevice) -> (any MTLTexture)? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .depth32Float,
            width: 2048, height: 2048,
            mipmapped: false
        )

        desc.storageMode = .private
        desc.usage = [.renderTarget, .shaderRead]

        return device.makeTexture(descriptor: desc)
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

        target.encode(with: .init(raw: encoder))
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

extension Shader.D3.Shadow.PipelineStates {
    static func make(with device: any MTLDevice) throws -> any MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        desc.depthAttachmentPixelFormat = .depth32Float

        do {
            let lib = device.makeDefaultLibrary()!
            desc.vertexFunction = lib.makeFunction(name: "D3::Shadow::vertexMain")!
        }

        desc.vertexDescriptor = Shader.D3.Mesh.PipelineStates.describe()

        return try device.makeRenderPipelineState(descriptor: desc)
    }
}

extension Shader.D3.Shadow.PipelineStates {
    static func make(with device: any MTLDevice) -> (any MTLDepthStencilState)? {
        let desc = MTLDepthStencilDescriptor.init()

        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .less

        return device.makeDepthStencilState(descriptor: desc)
    }
}

extension Shader.D3.Shadow {
    struct Encoder {
        var raw: any MTLRenderCommandEncoder
    }
}

extension Shader.D3.Shadow {
    typealias Encodable = _ShaderD3ShadowEncodable
}

protocol _ShaderD3ShadowEncodable {
    func encode(with encoder: Shader.D3.Shadow.Encoder)
}
