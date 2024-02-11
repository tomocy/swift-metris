// tomocy

import Metal

protocol MTLFrameRenderCommandEncodable {
    func encode(to encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    func encode(to encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}
