// tomocy

import Metal

protocol MTLRenderCommandEncodableAt {
    func encode(to encoder: MTLRenderCommandEncoder, at index: Int)
}
