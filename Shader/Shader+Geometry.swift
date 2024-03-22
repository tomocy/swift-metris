// tomocy

import simd

extension Shader {
    enum D3 {
        typealias Measure = SIMD3<Float>
        typealias Coordinate = SIMD4<Float>
        typealias Matrix = float4x4
    }
}

extension Shader.D3 {
    enum Positions {
        struct InNDC {
            var value: Measure
        }

        struct InClip {
            var value: Coordinate
        }

        struct InView {
            var value: Coordinate
        }

        struct InWorld {
            var value: Coordinate
        }
    }
}

extension Shader.D3 {
    struct Aspect {
        var projection: Matrix
        var view: Matrix
    }
}
