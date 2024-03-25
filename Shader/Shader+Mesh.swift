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

        target.encode(in: .init(encoder: encoder))
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

        // float3 position
        stride += describe(
            to: desc.attributes[0],
            format: .float3,
            offset: stride,
            bufferIndex: 0
        )

        // float3 normal
        stride += describe(
            to: desc.attributes[1],
            format: .float3,
            offset: stride,
            bufferIndex: 0
        )

        // float2 texture.coordinate
        stride += describe(
            to: desc.attributes[2],
            format: .float2,
            offset: stride,
            bufferIndex: 0
        )

        desc.layouts[0].stride = stride

        return desc
    }

    static func describe(
        to descriptor: MTLVertexAttributeDescriptor,
        format: MTLVertexFormat,
        offset: Int,
        bufferIndex: Int
    ) -> Int {
        descriptor.format = format
        descriptor.offset = offset
        descriptor.bufferIndex = bufferIndex

        switch format {
        case .float2:
            return MemoryLayout<SIMD2<Float>>.stride
        case .float3:
            return MemoryLayout<SIMD3<Float>.Packed>.stride
        default:
            return 0
        }
    }
}

extension Shader.D3.Mesh.PipelineStates {
    static func describe() -> MDLVertexDescriptor {
        let desc = MDLVertexDescriptor.init()

        var stride = 0

        let attrs = desc.attributes as! [MDLVertexAttribute]

        stride += describe(
            to: attrs[0],
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: stride,
            bufferIndex: 0
        )

        stride += describe(
            to: attrs[1],
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: stride,
            bufferIndex: 0
        )

        stride += describe(
            to: attrs[2],
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: stride,
            bufferIndex: 0
        )

        let layouts = desc.layouts as! [MDLVertexBufferLayout]
        layouts[0].stride = stride

        return desc
    }

    static func describe(
        to attribute: MDLVertexAttribute,
        name: String,
        format: MDLVertexFormat,
        offset: Int,
        bufferIndex: Int
    ) -> Int {
        attribute.name = name
        attribute.format = format
        attribute.offset = offset
        attribute.bufferIndex = bufferIndex

        switch format {
        case .float2:
            return MemoryLayout<SIMD2<Float>>.stride
        case .float3:
            return MemoryLayout<SIMD3<Float>.Packed>.stride
        default:
            return 0
        }
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
    struct Context {
        var encoder: any MTLRenderCommandEncoder
    }
}

extension Shader.D3.Mesh {
    typealias Encodable = _ShaderD3MeshEncodable
}

protocol _ShaderD3MeshEncodable {
    func encode(in context: Shader.D3.Mesh.Context)
}
