// tomocy

import Metal

enum Shader {}

extension Shader.D3 {
    struct Shader {
        var commandQueue: MTLCommandQueue
        var shadow: Shadow
        var mesh: Mesh
    }
}

extension Shader.D3.Shader {
    init(device: any MTLDevice) {
        commandQueue = device.makeCommandQueue()!
        shadow = .init(device: device)
        mesh = .init(device: device)
    }
}
