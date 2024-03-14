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
protocol MTLFrameRenderCommandEncodableAs {
    mutating func encode(
        with encoder: MTLRenderCommandEncoder,
        as descriptor: MTLRenderPipelineDescriptor, 
        in frame: MTLRenderFrame
    )
}

protocol MTLFrameRenderCommandEncodableAsAt {
    mutating func encode(
        with encoder: MTLRenderCommandEncoder,
        as descriptor: MTLRenderPipelineDescriptor,
        at index: Int,
        in frame: MTLRenderFrame
    )
}

protocol MTLFrameRenderCommandEncodable {
    mutating func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame)
}

protocol MTLFrameRenderCommandEncodableAt {
    mutating func encode(with encoder: MTLRenderCommandEncoder, at index: Int, in frame: MTLRenderFrame)
}

protocol MTLRenderCommandEncodableAsToAt {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        as descriptor: MTLRenderPipelineDescriptor,
        to buffer: MTLBuffer,
        at index: Int
    )
}

protocol MTLRenderCommandEncodableAsToIndexedAt {
    func encode(
        with encoder: MTLRenderCommandEncoder,
        as descriptor: MTLRenderPipelineDescriptor,
        to buffer: Indexed<MTLBuffer>,
        at index: Int
    )
}

protocol MTLRenderCommandEncodableToAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: MTLBuffer, at index: Int)
}

protocol MTLRenderCommandEncodableToIndexedAt {
    func encode(with encoder: MTLRenderCommandEncoder, to buffer: Indexed<MTLBuffer>, at index: Int)
}
