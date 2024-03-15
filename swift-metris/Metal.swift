// tomocy

import Metal

struct MTLRenderFrame {
    let id: Int
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
        return buffers.contains { (i, buffer) in
            return i == index
                && buffer.length == size
        }
    }

    let options: MTLResourceOptions
    private var buffers: [Int: MTLBuffer] = [:]
}

protocol MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor)
}

extension MTLRenderPipelineDescriptor {
    func describe(with device: MTLDevice) -> MTLRenderPipelineState? {
        return try? device.makeRenderPipelineState(descriptor: self)
    }
}

// MTLFrameRenderCommandEncodable encodes itself using the buffer assigned for the frame.
// It should use the buffer if its size matches the encoding one.
// Otherwise it should make a new buffer, use and retain it for subsequent calls.
//
protocol MTLFrameRenderCommandEncodable {
    mutating func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    mutating func encode(with encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}

protocol MTLRenderCommandEncodableTo {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: MTLBuffer, by offset: Int
    )
}

extension MTLRenderCommandEncodableTo {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: MTLBuffer, by offset: Int = 0
    ) {
        encode(with: encoder, to: buffer, by: offset)
    }
}

protocol MTLRenderCommandEncodableToIndexed {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int>
    )
}

extension MTLRenderCommandEncodableToIndexed {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int> = .init(data: 0, index: 0)
    ) {
        encode(with: encoder, to: buffer, by: offset)
    }
}

protocol MTLRenderCommandEncodableToAt {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: MTLBuffer, by offset: Int,
        at index: Int
    )
}

protocol MTLRenderCommandEncodableToIndexedAt {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        to buffer: Indexed<MTLBuffer>, by offset: Indexed<Int>,
        at index: Int
    )
}
