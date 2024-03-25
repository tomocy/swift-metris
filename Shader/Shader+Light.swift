// tomocy

import Metal

extension Shader.D3 {
    struct Light {
        var color: SIMD3<Float>
        var intensity: Float
        var aspect: Aspect
    }
}

extension Shader.D3 {
    struct Lights {
        var ambient: Light
        var directional: Light
        var point: Light
    }
}

extension Shader.D3.Lights {
    func encode(in context: some Shader.RenderContext) {
        let buffer = context.buffers.take(
            at: "Lights",
            of: MemoryLayout<Self>.stride,
            options: .storageModeShared
        )!

        encode(with: context.encoder, to: buffer)
    }

    func encode(with encoder: some MTLRenderCommandEncoder, to buffer: some MTLBuffer) {
        IO.writable(self).write(to: buffer)
        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
    }
}
