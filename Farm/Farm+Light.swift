// tomocy

extension Farm {
    enum Lights {}
}

extension Farm.Lights {
    struct Ambient {
        var color: SIMD3<Float>
        var intensity: Float
    }
}
