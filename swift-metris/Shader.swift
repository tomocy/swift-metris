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
        var textures: Textures
        var states: States
    }
}

extension D3.XShader {
    init(device: MTLDevice, formats: MTLPixelFormats) throws {
        commandQueue = device.makeCommandQueue()!

        textures = .init(
            shadow: Textures.makeShadow(with: device)!
        )

        states = .init(
            shadow: try States.makeShadow(with: device),
            render: try States.makeRender(with: device, formats: formats),
            depthStencil: States.makeDepthStencil(with: device)!,
            sampler: States.makeSampler(with: device)!
        )
    }
}

extension D3.XShader {
    func shadow(_ target: D3.XWorld, to buffer: MTLCommandBuffer) {
        let desc = MTLRenderPassDescriptor.init()

        do {
            let attachment = desc.depthAttachment!

            attachment.texture = textures.shadow

            attachment.loadAction = .clear
            attachment.clearDepth = 1

            attachment.storeAction = .store
        }

        let encoder = buffer.makeRenderCommandEncoder(descriptor: desc)!
        defer { encoder.endEncoding() }

        do {
            encoder.setCullMode(.back)

            encoder.setRenderPipelineState(states.shadow)
            encoder.setDepthStencilState(states.depthStencil)
            encoder.setFragmentSamplerState(states.sampler, index: 0)
        }

        do {
            let size = SIMD2<Float>.init(800, 800)
            let depth = size.min()
            let (w, h, d) = (size.x * 0.05, size.y * 0.05, depth * 0.05)
            let projection = D3.Transform<Float>.orthogonal(
                top: w, bottom: -w,
                left: -h, right: h,
                near: 0, far: d * 4
            ).resolve()

            let view = ({
                let wFrom = D3.Storage<Float>.init(w, h, -d)
                let wTo = D3.Storage<Float>.init(0, 0, 0)
                let wUp = D3.Storage<Float>.init(0, 1, 0)

                let forward = normalize(wTo - wFrom)
                let right = normalize(cross(wUp, forward))
                let up = normalize(cross(forward, right))

                return D3.Matrix(
                    columns: [
                        .init(right, 0),
                        .init(up, 0),
                        .init(forward, 0),
                        .init(wFrom, 1)
                    ]
                ).inverse
            }) ()

            target.shadow(with: encoder, from: projection * view)
        }
    }
}

extension D3.XShader {
    func render(_ target: D3.XWorld, to buffer: MTLCommandBuffer, as descriptor: MTLRenderPassDescriptor) {
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        defer { encoder.endEncoding() }

        encoder.setCullMode(.back)

        encoder.setRenderPipelineState(states.render)
        encoder.setDepthStencilState(states.depthStencil)
        encoder.setFragmentSamplerState(states.sampler, index: 0)

        do {
            let projection = ({
                let near: Float = 1
                let far: Float = 1000

                let aspectRatio: Float = 800 / 800
                let fovX: Float = Angle.init(degree: 120).inRadian()
                var scale = SIMD2<Float>.init(1, 1)
                scale.x = 1 / tan(fovX / 2)
                scale.y = scale.x * aspectRatio

                return D3.Matrix(
                    rows: [
                        .init(scale.x, 0, 0, 0),
                        .init(0, scale.y, 0, 0),
                        .init(0, 0, far / (far - near), -(far * near) / (far - near)),
                        .init(0, 0, 1, 0)
                    ]
                )
            }) ()

            let view = D3.Transform<Float>(
                translate: .init(0, -20, 35)
            ).resolve()

            target.render(with: encoder, from: projection * view)
        }
    }
}

extension D3.XShader {
    struct Textures {
        var shadow: MTLTexture
    }
}

extension D3.XShader.Textures {
    static func makeShadow(with device: MTLDevice) -> MTLTexture? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .depth32Float,
            width: 2048, height: 2048,
            mipmapped: false
        )

        desc.storageMode = .private
        desc.usage = [.renderTarget]

        return device.makeTexture(descriptor: desc)
    }
}

extension D3.XShader {
    struct States {
        var shadow: MTLRenderPipelineState
        var render: MTLRenderPipelineState
        var depthStencil: MTLDepthStencilState
        var sampler: MTLSamplerState
    }
}

extension D3.XShader.States {
    static func makeShadow(with device: MTLDevice) throws -> MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        desc.depthAttachmentPixelFormat = .depth32Float

        do {
            let lib = device.makeDefaultLibrary()!
            desc.vertexFunction = lib.makeFunction(name: "D3::X::shadowMain")!
        }

        desc.vertexDescriptor = describeVertexAttributes()

        return try device.makeRenderPipelineState(descriptor: desc)
    }
}

extension D3.XShader.States {
    static func makeRender(
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
            desc.vertexDescriptor = describeVertexAttributes()

            Log.debug("D3.Shader: VertexDescriptor ---")
            Log.debug("\(desc.vertexDescriptor!)")
        }

        return try device.makeRenderPipelineState(descriptor: desc)
    }

    private static func describeVertexAttributes() -> MTLVertexDescriptor {
        let desc = MTLVertexDescriptor.init()

        var stride = 0

        do {
            // float3 position
            describeVertexAttribute(at: 0, to: desc, format: .float3, offset: stride, bufferIndex: 0)
            stride += MemoryLayout<SIMD3<Float>.Packed>.stride
        }
        do {
            // float3 normal
            describeVertexAttribute(at: 1, to: desc, format: .float3, offset: stride, bufferIndex: 0)
            stride += MemoryLayout<SIMD3<Float>.Packed>.stride
        }
        do {
            // float2 textureCoordinate
            describeVertexAttribute(at: 2, to: desc, format: .float2, offset: stride, bufferIndex: 0)
            stride += MemoryLayout<SIMD2<Float>>.stride
        }

        desc.layouts[0].stride = stride

        return desc
    }

    private static func describeVertexAttribute(
        at index: Int,
        to descriptor: MTLVertexDescriptor,
        format: MTLVertexFormat,
        offset: Int,
        bufferIndex: Int
    ) {
        descriptor.attributes[index].format = format
        descriptor.attributes[index].offset = offset
        descriptor.attributes[index].bufferIndex = bufferIndex
    }
}

extension D3.XShader.States {
    static func makeDepthStencil(with device: MTLDevice) -> MTLDepthStencilState? {
        let desc = MTLDepthStencilDescriptor.init()

        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .less

        return device.makeDepthStencilState(descriptor: desc)
    }
}

extension D3.XShader.States {
    static func makeSampler(with device: MTLDevice) -> MTLSamplerState? {
        let desc = MTLSamplerDescriptor.init()

        desc.normalizedCoordinates = true

        desc.magFilter = .linear
        desc.minFilter = .linear

        desc.sAddressMode = .repeat
        desc.tAddressMode = .repeat

        return device.makeSamplerState(descriptor: desc)
    }
}
