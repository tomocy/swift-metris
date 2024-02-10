// tomocy

import Metal

protocol MTLRenderCommandEncodable {
    func encode(to encoder: MTLRenderCommandEncoder)
}

protocol MTLRenderCommandEncodableAt {
    func encode(to encoder: MTLRenderCommandEncoder, at index: Int)
}
