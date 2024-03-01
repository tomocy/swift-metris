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
            Log.debug("MTLBuffer: Generated", with: [
                ("Index", "\(index)"),
                ("Size", "\(size)"),
            ])
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

protocol MTLRenderCommandEncodableToAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLBuffer, at index: Int)
}

protocol MTLRenderCommandEncodableToIndexedAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLIndexedBuffer, at index: Int)
}

// MTLFrameRenderCommandEncodable encodes itself using the buffer assigned for the frame.
// It should use the buffer if its size matches the encoding one.
// Otherwise it should make a new buffer, use and retain it for subsequent calls.
protocol MTLFrameRenderCommandEncodable {
    mutating func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    mutating func encode(with encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}
