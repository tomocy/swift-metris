// tomocy

import CoreGraphics
import Metal

extension Shader {
    enum Texture {}
}

extension Shader.Texture {
    struct Reference {
        var coordinate: SIMD2<Float>
    }
}
