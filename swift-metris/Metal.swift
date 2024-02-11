// tomocy

import Metal

struct MTLRenderFrame {
    let id: Int
}

struct MTLIndexedBuffer {
    var data: MTLBuffer
    var index: MTLBuffer
}

protocol MTLRenderCommandEncodableWithIndexedAt {
    func encode(to encoder: MTLRenderCommandEncoder, with buffer: MTLIndexedBuffer, at index: Int)
}

protocol MTLFrameRenderCommandEncodable {
    mutating func encode(to encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    mutating func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}
