// tomocy

import ModelIO
import Metal

extension Shader.D3 {
    struct Mesh {
        var pipelineStates: PipelineStates
    }
}

extension Shader.D3.Mesh {
    init(device: any MTLDevice) {
        pipelineStates = .init(
            render: try! PipelineStates.make(with: device),
            depthStencil: PipelineStates.make(with: device)!
        )
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

        target.encode(with: .init(raw: encoder))
    }
}

extension Shader.D3.Mesh {
    struct PipelineStates {
        var render: any MTLRenderPipelineState
        var depthStencil: any MTLDepthStencilState
    }
}

extension Shader.D3.Mesh.PipelineStates {
    static func make(with device: any MTLDevice) throws -> any MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        desc.rasterSampleCount = 4

        do {
            let attach = desc.colorAttachments[0]!

            attach.pixelFormat = .bgra8Unorm_srgb

            attach.isBlendingEnabled = true
            do {
                attach.sourceRGBBlendFactor = .one
                attach.destinationRGBBlendFactor = .oneMinusSourceAlpha
                attach.rgbBlendOperation = .add
            }
            do {
                attach.sourceAlphaBlendFactor = .one
                attach.destinationAlphaBlendFactor = .oneMinusSourceAlpha
                attach.rgbBlendOperation = .add
            }
        }

        desc.depthAttachmentPixelFormat = .depth32Float

        do {
            let lib = device.makeDefaultLibrary()!

            desc.vertexFunction = lib.makeFunction(name: "D3::Mesh::vertexMain")!
            desc.fragmentFunction = lib.makeFunction(name: "D3::Mesh::fragmentMain")!
        }

        desc.vertexDescriptor = describe()

        return try device.makeRenderPipelineState(descriptor: desc)
    }

    static func describe() -> MTLVertexDescriptor {
        let desc = MTLVertexDescriptor.init()

        var stride = 0

        do {
            // float3 position
            desc.attributes[0] = describe(format: .float3, offset: stride, bufferIndex: 0)
            stride += MemoryLayout<SIMD3<Float>.Packed>.stride
        }
        do {
            // float3 normal
            desc.attributes[1] = describe(format: .float3, offset: stride, bufferIndex: 0)
            stride += MemoryLayout<SIMD3<Float>.Packed>.stride
        }
        do {
            // float2 textureCoordinate
            desc.attributes[2] = describe(format: .float2, offset: stride, bufferIndex: 0)
            stride += MemoryLayout<SIMD2<Float>>.stride
        }

        desc.layouts[0].stride = stride

        return desc
    }

    static func describe(
        format: MTLVertexFormat,
        offset: Int,
        bufferIndex: Int
    ) -> MTLVertexAttributeDescriptor {
        let desc = MTLVertexAttributeDescriptor.init()

        desc.format = format
        desc.offset = offset
        desc.bufferIndex = bufferIndex

        return desc
    }
}

extension Shader.D3.Mesh.PipelineStates {
    static func make(with device: any MTLDevice) -> (any MTLDepthStencilState)? {
        let desc = MTLDepthStencilDescriptor.init()

        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .less

        return device.makeDepthStencilState(descriptor: desc)
    }
}

extension Shader.D3.Mesh {
    struct Encoder {
        var raw: any MTLRenderCommandEncoder
    }
}

extension Shader.D3.Mesh {
    typealias Encodable = _ShaderD3MeshEncodable
}

protocol _ShaderD3MeshEncodable {
    func encode(with encoder: Shader.D3.Mesh.Encoder)
}
