// tomocy

import Metal

enum IO {
    typealias Writable = _Writable
}

protocol _Writable {
    func write(to destination: UnsafeMutableRawPointer)
}

extension IO.Writable where Self: FixedWidthInteger {
    func write(to destination: UnsafeMutableRawPointer) {
        withUnsafeBytes(of: self) { bytes in
            destination.copy(from: bytes.baseAddress!, count: bytes.count)
        }
    }
}

extension IO.Writable {
    func write(to destination: MTLBuffer, by offset: Int = 0) {
        write(to: destination.contents().advanced(by: offset))
    }
}

extension UInt16: IO.Writable {}
extension UInt32: IO.Writable {}
