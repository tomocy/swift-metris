// tomocy

extension Array {
    var size: Int { MemoryLayout<Element>.stride * count }
}

extension Array: IO.Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        withUnsafeBytes { bytes in
            destination.copy(from: bytes.baseAddress!, count: bytes.count)
        }
    }

    func write(to destination: UnsafeMutableRawPointer) where Element: IO.Writable {
        enumerated().forEach { i, v in
            v.write(to: destination + MemoryLayout.stride(ofValue: v) * i)
        }
    }
}
