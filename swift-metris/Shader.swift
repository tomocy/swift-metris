// tomocy

import Metal

extension D3 {
    struct Shader {}
}

extension D3.Shader: MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "D3::vertexMain")!
        descriptor.fragmentFunction = lib.makeFunction(name: "D3::fragmentMain")!
    }
}
