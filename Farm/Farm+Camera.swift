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
    static func perspective(
        near: Float, far: Float,
        aspectRatio: Float, fovY: Float,
        transform: D3.Transform<Float>
    ) -> Self {
        let projection = ({
            let scale = ({
                let aspectRatio: Float = 1800 / 1200
                let fovY: Float = .pi / 3

                var scale = SIMD2<Float>.init(1, 1)
                scale.y = 1 / tan(fovY / 2)
                scale.x = scale.y / aspectRatio // 1 / w = (1 / h) * (h / w)

                return scale
            }) ()

            return float4x4(
                rows: [
                    .init(scale.x, 0, 0, 0),
                    .init(0, scale.y, 0, 0),
                    .init(0, 0, far / (far - near), -(far * near) / (far - near)),
                    .init(0, 0, 1, 0)
                ]
            )
        }) ()

        return .init(
            projection: projection,
            transform: transform
        )
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
