// tomocy

import simd
import Metal

extension Shader.D3 {
    struct Model {
        var transform: float4x4
    }
}

extension Array where Element == Shader.D3.Model {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let buffer = encoder.device.makeBuffer(
            length: MemoryLayout<Element>.stride * count,
            options: .storageModeShared
        )!
        buffer.label = "Models: {Count: \(count)}"

        IO.writable(self).write(to: buffer)

        encoder.setVertexBuffer(buffer, offset: 0, index: 2)
    }
}
