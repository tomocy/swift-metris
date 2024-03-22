// tomocy

import Metal

enum Material {}

extension Material {
    struct Source {
        var diffuse: Texture.Source?
    }
}

extension Material.Source: Equatable, Hashable {}

extension Material.Source {
    func encode(with encoder: MTLRenderCommandEncoder) {
        encoder.setFragmentTexture(diffuse?.raw, index: 0)
    }
}

extension Material {
    struct Reference {
        var diffuse: Shader.Texture.Reference?
    }
}
