// tomocy

import Metal

struct Camera {
    struct Raw {
        let projection: Matrix2D.Raw
        let transform: Matrix2D.Raw
    }

    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        var raw = Raw(
            projection: projection.apply().raw,
            transform: Transform2D(
                translate: -transform.translate,
                rotate: -transform.rotate,
                scale: transform.scale
            ).apply().raw
        )

        let buffer = encoder.device.makeBuffer(
            bytes: &raw,
            length: MemoryLayout<Raw>.stride,
            options: .storageModeShared
        );

        encoder.setVertexBuffer(buffer, offset: 0, index: index)
    }

    let projection: Transform2D
    let transform: Transform2D
}

