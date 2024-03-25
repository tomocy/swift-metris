// tomocy

import simd
import Metal

extension Shader.D3 {
    struct Model {
        var transform: float4x4
    }
}

extension Array where Element == Shader.D3.Model {
    func encode(in context: some Shader.RenderContext, key: String) {
        let buffer = context.buffers.take(
            at: key,
            of: MemoryLayout<Element>.stride * count,
            options: .storageModeShared
        )!

        encode(with: context.encoder, to: buffer)
    }

    func encode(with encoder: some MTLRenderCommandEncoder, to buffer: some MTLBuffer) {
        Shader.IO.writable(self).write(to: buffer)
        encoder.setVertexBuffer(buffer, offset: 0, index: 2)
    }
}
