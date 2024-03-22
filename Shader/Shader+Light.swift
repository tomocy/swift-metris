// tomocy

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
