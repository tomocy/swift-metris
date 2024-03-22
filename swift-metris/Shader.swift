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
        var resolution: SIMD2<Float>
        var textures: Textures
        var states: States
    }
}

extension D3.XShader {
    init(device: MTLDevice, resolution: SIMD2<Float>, sampleCount: Int, formats: MTLPixelFormats) throws {
        commandQueue = device.makeCommandQueue()!

        self.resolution = resolution

        textures = .init(
            shadow: Textures.makeShadow(with: device)!
        )

        states = .init(
            shadow: try States.makeShadow(with: device),
            mesh: try States.makeMesh(with: device, sampleCount: sampleCount, formats: formats),
            depthStencil: States.makeDepthStencil(with: device)!,
            sampler: States.makeSampler(with: device)!
        )
    }
}

extension D3.XShader {
    func renderShadow(_ target: D3.XWorld, to buffer: MTLCommandBuffer) {
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

        target.renderShadow(with: encoder, light: makeLightAspect())
    }
}

extension D3.XShader {
    func renderMesh(_ target: D3.XWorld, to buffer: MTLCommandBuffer, as descriptor: MTLRenderPassDescriptor) {
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        defer { encoder.endEncoding() }

        encoder.setCullMode(.back)

        encoder.setRenderPipelineState(states.mesh)
        encoder.setDepthStencilState(states.depthStencil)
        encoder.setFragmentSamplerState(states.sampler, index: 0)

        encoder.setFragmentTexture(textures.shadow, index: 0)

        target.renderMesh(
            with: encoder,
            light: makeLightAspect(),
            view: makeViewAspect()
        )
    }
}

extension D3.XShader {
    private func makeLightAspect() -> Aspect {
        /* let size = SIMD2<Float>.init(800, 800)
        let depth = size.min()
        let (w, h, d) = (size.x * 0.05, size.y * 0.05, depth * 0.05) */

        let projection = D3.Transform<Float>.orthogonal(
            top: 1.5, bottom: -1.5,
            left: -1.5, right: 1.5,
            near: 0, far: 10
        ).resolve()

        let view = D3.Transform<Float>.look(
            from: .init(1, 1, -1),
            to: .init(0, 0, 0),
            up: .init(0, 1, 0)
        ).inverse

        return .init(
            projection: projection,
            view: view
        )
    }

    private func makeViewAspect() -> Aspect {
        let projection = ({
            let near: Float = 0.01
            let far: Float = 100

            let scale = ({
                let aspectRatio: Float = resolution.x / resolution.y
                let fovY: Float = .pi / 3

                var scale = SIMD2<Float>.init(1, 1)
                scale.y = 1 / tan(fovY / 2)
                scale.x = scale.y / aspectRatio // 1 / w = (1 / h) * (h / w)

                return scale
            }) ()

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
            translate: .init(0, 0.5, -2)
        ).inversed(
            rotate: false, scale: false
        ).resolve()

        return .init(
            projection: projection,
            view: view
        )
    }
}

extension D3.XShader {
    struct Aspect {
        var projection: D3.Matrix
        var view: D3.Matrix
    }
}

extension D3.XShader {
    struct Model {
        var transform: D3.Matrix
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
        desc.usage = [.renderTarget, .shaderRead]

        return device.makeTexture(descriptor: desc)
    }
}

extension D3.XShader {
    struct States {
        var shadow: MTLRenderPipelineState
        var mesh: MTLRenderPipelineState
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
            desc.vertexFunction = lib.makeFunction(name: "D3::X::shadowVertex")!
        }

        desc.vertexDescriptor = describeVertexAttributes()

        return try device.makeRenderPipelineState(descriptor: desc)
    }
}

extension D3.XShader.States {
    static func makeMesh(
        with device: MTLDevice,
        sampleCount: Int,
        formats: MTLPixelFormats
    ) throws -> MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        desc.rasterSampleCount = sampleCount

        do {
            let attachment = desc.colorAttachments[0]!

            attachment.pixelFormat = formats.color

            attachment.isBlendingEnabled = true
            do {
                attachment.sourceRGBBlendFactor = .one
                attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
                attachment.rgbBlendOperation = .add
            }
            do {
                attachment.sourceAlphaBlendFactor = .one
                attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
                attachment.rgbBlendOperation = .add
            }
        }

        desc.depthAttachmentPixelFormat = formats.depthStencil

        do {
            let lib = device.makeDefaultLibrary()!

            desc.vertexFunction = lib.makeFunction(name: "D3::X::meshVertex")!
            desc.fragmentFunction = lib.makeFunction(name: "D3::X::meshFragment")!
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
