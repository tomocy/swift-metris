// tomocy

import simd

extension Shader {
    enum D3 {}
}

extension Shader.D3 {
    enum Coordinates {
        struct InNDC {
            var value: SIMD3<Float>
        }

        struct InClip {
            var value: SIMD4<Float>
        }

        struct InView {
            var value: SIMD4<Float>
        }

        struct InWorld {
            var value: SIMD4<Float>
        }

        struct WVC {
            var inWorld: InWorld
            var inView: InView
            var inClip: InClip
        }
    }
}

extension Shader.D3 {
    struct Aspect {
        var projection: float4x4
        var view: float4x4
    }
}
