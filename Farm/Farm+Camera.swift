// tomocy

import simd
import Metal

extension Farm {
    struct Camera {
        var projection: float4x4
        var transform: D3.Transform<Float>
    }
}

extension Farm.Camera {
    func encode(with encoder: any MTLRenderCommandEncoder) {
        let aspect = Shader.D3.Aspect.init(
            projection: projection,
            view: transform.inversed(
                rotate: false, scale: false
            ).resolve()
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
