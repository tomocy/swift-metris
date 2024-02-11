// tomocy

import Metal

struct MTLRenderFrame {
    let id: Int
}

struct MTLIndexedBuffer {
    var data: MTLBuffer
    var index: MTLBuffer
}

protocol MTLRenderCommandEncodableWithIndexedBufferAt {
    func encode(to encoder: MTLRenderCommandEncoder, with buffer: MTLIndexedBuffer, at index: Int)
}

protocol MTLFrameRenderCommandEncodable {
    func encode(to encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}
