// tomocy

import Metal

struct MTLRenderFrame {
    let id: Int
}

struct MTLIndexedBuffer {
    var data: MTLBuffer
    var index: MTLBuffer
}

struct MTLSizedBuffers {
    init(options: MTLResourceOptions = []) {
        self.options = options
    }

    mutating func take(at index: Int, of size: Int, with device: MTLDevice) -> MTLBuffer {
        if !has(at: index, of: size) {
            buffers[index] = device.makeBuffer(
                length: size,
                options: options
            )
            NSLog("buffer: generated: size: \(size)")
        }

        return buffers[index]!
    }

    func has(at index: Int, of size: Int) -> Bool {
        return buffers.contains(
            where: { (i, buffer) in
                return i == index
                    && buffer.length == size
            }
        )
    }

    private var options: MTLResourceOptions = []
    private var buffers: [Int: MTLBuffer] = [:]
}

protocol MTLRenderCommandEncodableWithAt {
    func encode(to encoder: MTLRenderCommandEncoder, with buffer: MTLBuffer, at index: Int)
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
