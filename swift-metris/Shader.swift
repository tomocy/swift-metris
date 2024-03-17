// tomocy

import Metal

extension D3 {
    struct Shader {
        var commandQueue: MTLCommandQueue
        var pipelineStates: PipelineStates
    }
}

extension D3.Shader {
    init(device: MTLDevice, pixelFormat: MTLPixelFormat) throws {
        commandQueue = device.makeCommandQueue()!

        pipelineStates = .init(
            render: try PipelineStates.make(with: device, pixelFormat: pixelFormat)
        )
    }
}

extension D3.Shader {
    func encode<T: MTLFrameRenderCommandEncodable>(
        _ target: inout T,
        with encoder: MTLRenderCommandEncoder,
        at frame: MTLRenderFrame
    ) {
        encoder.setRenderPipelineState(pipelineStates.render)

        target.encode(with: encoder, in: frame)
    }
}

extension D3.Shader {
    struct PipelineStates {
        var render: MTLRenderPipelineState
    }
}

extension D3.Shader.PipelineStates {
    static func make(with device: MTLDevice, pixelFormat: MTLPixelFormat) throws -> MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        desc.colorAttachments[0]?.pixelFormat = pixelFormat

        do {
            let lib = device.makeDefaultLibrary()!

            desc.vertexFunction = lib.makeFunction(name: "D3::vertexMain")!
            desc.fragmentFunction = lib.makeFunction(name: "D3::fragmentMain")!
        }

        return try device.makeRenderPipelineState(descriptor: desc)
    }
}

extension D3 {
    struct XShader {
        var commandQueue: MTLCommandQueue
        var pipelineStates: PipelineStates
    }
}

extension D3.XShader {
    init(device: MTLDevice, formats: MTLPixelFormats) throws {
        commandQueue = device.makeCommandQueue()!

        pipelineStates = .init(
            render: try PipelineStates.make(with: device, formats: formats),
            depthStencil: PipelineStates.make(with: device)
        )
    }
}

extension D3.XShader {
    func encode<T: MTLFrameRenderCommandEncodable>(
        _ target: inout T,
        with encoder: MTLRenderCommandEncoder,
        at frame: MTLRenderFrame
    ) {
        encoder.setRenderPipelineState(pipelineStates.render)
        encoder.setDepthStencilState(pipelineStates.depthStencil)

        target.encode(with: encoder, in: frame)
    }
}

extension D3.XShader {
    struct PipelineStates {
        var render: MTLRenderPipelineState
        var depthStencil: MTLDepthStencilState
    }
}

extension D3.XShader.PipelineStates {
    static func make(
        with device: MTLDevice,
        formats: MTLPixelFormats
    ) throws -> MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        do {
            let attachment = desc.colorAttachments[0]!

            attachment.pixelFormat = formats.color
        }

        desc.depthAttachmentPixelFormat = formats.depthStencil

        do {
            let lib = device.makeDefaultLibrary()!

            desc.vertexFunction = lib.makeFunction(name: "D3::X::vertexMain")!
            desc.fragmentFunction = lib.makeFunction(name: "D3::X::fragmentMain")!
        }

        do {
            desc.vertexDescriptor = .init()
            let vertex = desc.vertexDescriptor!
            var stride = 0

            do {
                // float3 position
                describe(0, to: vertex, format: .float3, offset: stride, bufferIndex: 0)
                stride += MemoryLayout<SIMD3<Float>.Packed>.stride
            }
            do {
                // float3 normal
                describe(1, to: vertex, format: .float3, offset: stride, bufferIndex: 0)
                stride += MemoryLayout<SIMD3<Float>.Packed>.stride
            }
            do {
                // float2 textureCoordinate
                describe(2, to: vertex, format: .float2, offset: stride, bufferIndex: 0)
                stride += MemoryLayout<SIMD2<Float>>.stride
            }

            vertex.layouts[0].stride = stride

            Log.debug("D3.Shader: VertexDescriptor ---")
            Log.debug("\(vertex)")
        }

        return try device.makeRenderPipelineState(descriptor: desc)
    }

    private static func describe(
        _ id: Int,
        to descriptor: MTLVertexDescriptor,
        format: MTLVertexFormat,
        offset: Int,
        bufferIndex: Int
    ) {
        descriptor.attributes[id].format = format
        descriptor.attributes[id].offset = offset
        descriptor.attributes[id].bufferIndex = bufferIndex
    }
}

extension D3.XShader.PipelineStates {
    static func make(with device: MTLDevice) -> MTLDepthStencilState {
        let desc = MTLDepthStencilDescriptor.init()

        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .less

        return device.makeDepthStencilState(descriptor: desc)!
    }
}
