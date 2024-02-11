// tomocy

import Metal

struct MTLRenderFrame {
    let id: Int
}

protocol MTLFrameRenderCommandEncodable {
    func encode(to encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}