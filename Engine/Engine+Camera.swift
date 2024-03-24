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
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let aspect = Shader.D3.Aspect.init(
            projection: projection,
            view: Engine.Functional(transform).state({
                $0.inverse(rotate: false, scale: false)
            }).generate().resolve()
        )

        do {
            let buffer = encoder.device.makeBuffer(
                length: MemoryLayout.stride(ofValue: aspect),
                options: .storageModeShared
            )!
            buffer.label = "Camera: Aspect"

            IO.writable(aspect).write(to: buffer)

            encoder.setVertexBuffer(buffer, offset: 0, index: 1)
        }
    }
}
