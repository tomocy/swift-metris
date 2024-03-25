// tomocy

import simd
import Metal

extension Engine.D3 {
    struct Camera {
        var projection: float4x4
        var transform: Transform
    }
}

extension Engine.D3.Camera {
    func encode(in context: some Shader.RenderContext) {
        let buffer = context.buffers.take(
            at: "Camera/Aspect",
            of: MemoryLayout<Shader.D3.Aspect>.stride,
            options: .storageModeShared
        )!

        encode(with: context.encoder, to: buffer)
    }

    func encode(with encoder: some MTLRenderCommandEncoder, to buffer: some MTLBuffer) {
        let aspect = Shader.D3.Aspect.init(
            projection: projection,
            view: Engine.Functional(transform).state({
                $0.inverse(rotate: false, scale: false)
            }).generate().resolve()
        )

        Shader.IO.writable(aspect).write(to: buffer)

        encoder.setVertexBuffer(buffer, offset: 0, index: 1)
    }
}
