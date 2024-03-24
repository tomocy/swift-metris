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
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let buffer = encoder.device.makeBuffer(
            length: MemoryLayout<Self>.stride,
            options: .storageModeShared
        )!
        buffer.label = "Lights"

        IO.writable(self).write(to: buffer)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
    }
}
