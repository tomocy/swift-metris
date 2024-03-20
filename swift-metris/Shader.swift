// tomocy

import Metal
import MetalKit

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
        var states: States
    }
}

extension D3.XShader {
    init(device: MTLDevice, formats: MTLPixelFormats) throws {
        commandQueue = device.makeCommandQueue()!

        states = .init(
            render: try States.make(with: device, formats: formats),
            depthStencil: States.make(with: device),
            sampler: States.make(with: device)
        )
    }
}

extension D3.XShader {
    func shadow(_ target: D3.XWorld, to buffer: MTLCommandBuffer, as descriptor: MTLRenderPassDescriptor) {
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        defer { encoder.endEncoding() }

        do {
            encoder.setCullMode(.back)

            encoder.setRenderPipelineState(states.render)
            encoder.setDepthStencilState(states.depthStencil)
            encoder.setFragmentSamplerState(states.sampler, index: 0)
        }

        do {
            let projection = D3.Transform<Float>.orthogonal(
                top: 50, bottom: -50,
                left: -50, right: 50,
                near: 0, far: 50
            ).resolve()

            let view = D3.Transform<Float>(
                translate: .init(0, -20, 35)
            ).resolve()

            target.shadow(with: encoder, matrix: projection * view)
        }
    }
}

extension D3.XShader {
    func encode(
        _ target: inout D3.XWorld,
        with encoder: MTLRenderCommandEncoder
    ) {
        encoder.setRenderPipelineState(states.render)
        encoder.setDepthStencilState(states.depthStencil)

        encoder.setFragmentSamplerState(states.sampler, index: 0)

        target.encode(with: encoder)
    }
}

extension D3.XShader {
    struct States {
        var render: MTLRenderPipelineState
        var depthStencil: MTLDepthStencilState
        var sampler: MTLSamplerState
    }
}

extension D3.XShader.States {
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

extension D3.XShader.States {
    static func make(with device: MTLDevice) -> MTLDepthStencilState {
        let desc = MTLDepthStencilDescriptor.init()

        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .less

        return device.makeDepthStencilState(descriptor: desc)!
    }
}

extension D3.XShader.States {
    static func make(with device: MTLDevice) -> MTLSamplerState {
        let desc = MTLSamplerDescriptor.init()

        desc.normalizedCoordinates = true

        desc.magFilter = .linear
        desc.minFilter = .linear

        desc.sAddressMode = .repeat
        desc.tAddressMode = .repeat

        return device.makeSamplerState(descriptor: desc)!
    }
}
