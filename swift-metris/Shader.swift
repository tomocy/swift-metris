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
    init(device: MTLDevice, pixelFormat: MTLPixelFormat) throws {
        commandQueue = device.makeCommandQueue()!

        pipelineStates = .init(
            render: try PipelineStates.make(with: device, pixelFormat: pixelFormat)
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

        target.encode(with: encoder, in: frame)
    }
}

extension D3.XShader {
    struct PipelineStates {
        var render: MTLRenderPipelineState
    }
}

extension D3.XShader.PipelineStates {
    static func make(with device: MTLDevice, pixelFormat: MTLPixelFormat) throws -> MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        desc.colorAttachments[0]?.pixelFormat = pixelFormat

        do {
            let lib = device.makeDefaultLibrary()!

            desc.vertexFunction = lib.makeFunction(name: "D3::X::vertexMain")!
            desc.fragmentFunction = lib.makeFunction(name: "D3::X::fragmentMain")!
        }

        do {
            desc.vertexDescriptor = .init()
            let vertex = desc.vertexDescriptor!
            var stride = 0

            vertex.attributes[0].format = .float3
            vertex.attributes[0].offset = stride
            vertex.attributes[0].bufferIndex = 0
            stride += MemoryLayout<SIMD3<Float>.Packed>.stride

            vertex.layouts[0].stride = stride
        }

        return try device.makeRenderPipelineState(descriptor: desc)
    }
}
