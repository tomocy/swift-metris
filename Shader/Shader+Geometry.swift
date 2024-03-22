// tomocy

import simd

extension Shader {
    enum D3 {
        typealias Measure = SIMD3<Float>
        typealias Matrix = float4x4
    }
}


extension Shader.D3 {
    struct Aspect {
        var projection: Matrix
        var view: Matrix
    }
}
