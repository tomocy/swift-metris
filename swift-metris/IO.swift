// tomocy

import Metal

enum IO {
    typealias Writable = _Writable
}

extension IO {
    static func write<T>(_ target: T, to destination: UnsafeMutableRawPointer) {
        withUnsafeBytes(of: target) { bytes in
            destination.copy(from: bytes.baseAddress!, count: bytes.count)
        }
    }
}

protocol _Writable {
    func write(to destination: UnsafeMutableRawPointer)
}

extension IO.Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        IO.write(self, to: destination)
    }
}

extension IO.Writable {
    func write(to destination: MTLBuffer, by offset: Int = 0) {
        write(to: destination.contents().advanced(by: offset))
    }
}

extension UInt16: IO.Writable {}
extension UInt32: IO.Writable {}
