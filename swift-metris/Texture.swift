// tomocy

import Metal

enum Texture {}

extension Texture {
    typealias Source = MTLTexture
}

extension Texture {
    struct Reference<P: Dimension.Precision> {
        var coordinate: SIMD2<Precision> = .init(0, 0)
    }
}

extension Texture.Reference {
    typealias Precision = P
}
