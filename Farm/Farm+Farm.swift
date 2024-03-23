 // tomocy

enum Farm {}

extension Farm {
    struct World {
        var camera: Camera
        var lights: Lights

        var spots: Mesh
        var monolith: Mesh
        var ground: Mesh
    }
}

extension Farm.World: Shader.D3.Shadow.Encodable {
    func encode(with encoder: Shader.D3.Shadow.Encoder) {
        lights.directional.encode(with: encoder.raw)

        do {
            spots.encode(with: encoder.raw)
            ground.encode(with: encoder.raw)
        }
        do {
            ground.encode(with: encoder.raw)
        }
    }
}
