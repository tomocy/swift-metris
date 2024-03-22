// tomocy

import Metal

enum IO {
    typealias Writable = _Writable
}

extension IO {
    static func writable<T>(_ target: T) -> IO.Writable {
        return IO.DefaultWritable.init(value: target)
    }

    static func writable<T: IO.Writable>(_ target: T) -> IO.Writable {
        return target
    }
}

protocol _Writable {
    func write(to destination: UnsafeMutableRawPointer)
}

extension IO.Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        IO.writable(self).write(to: destination)
    }
}

extension IO.Writable {
    func write(to destination: MTLBuffer, by offset: Int = 0) {
        write(to: destination.contents().advanced(by: offset))
    }
}

extension IO {
    fileprivate struct DefaultWritable<T> {
        var value: T
    }
}

extension IO.DefaultWritable: IO.Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        withUnsafeBytes(of: value) { bytes in
            destination.copy(from: bytes.baseAddress!, count: bytes.count)
        }
    }
}
