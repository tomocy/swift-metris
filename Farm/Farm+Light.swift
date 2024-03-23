// tomocy

extension Farm {
    struct Lights {}
}

extension Farm.Lights {
    struct Ambient {
        var color: SIMD3<Float>
        var intensity: Float
    }
}

extension Farm.Lights {
    struct Directional {
        var color: SIMD3<Float>
        var intensity: Float
        var direction: SIMD3<Float>
    }
}

extension Farm.Lights {
    struct Point {
        var color: SIMD3<Float>
        var intensity: Float
        var transform: D3.Transform<Float>
    }
}
