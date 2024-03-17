// tomocy

import Metal

extension SIMD3 {
    init(filled value: Scalar) {
        self.init(value, value, value)
    }
}

extension SIMD3<Float> {
    init(_ volume: CGVolume) {
        self.init(
            .init(volume.width),
            .init(volume.height),
            .init(volume.depth)
        )
    }
}

extension SIMD3<Float> {
    typealias Packed = MTLPackedFloat3
}

extension MTLPackedFloat3 {
    init(_ relaxed: SIMD3<Float>) {
        self.init(
            .init(elements: (relaxed.x, relaxed.y, relaxed.z))
        )
    }

    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(.init(x, y, z))
    }
}
