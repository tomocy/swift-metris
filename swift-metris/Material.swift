// tomocy

enum Material {}

extension Material {
    struct Source {
        var diffuse: Texture.Source
    }
}

extension Material {
    struct Reference {
        var diffuse: Texture.Reference<Float> = .init()
    }
}
