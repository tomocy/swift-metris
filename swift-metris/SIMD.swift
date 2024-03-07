// tomocy

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
