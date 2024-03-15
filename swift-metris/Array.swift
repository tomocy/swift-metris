// tomocy

extension Array {
    var size: Int { MemoryLayout<Element>.stride * count }
}

extension Array {
    func write(to destination: UnsafeMutableRawPointer) {
        for (i, v) in self.enumerated() {
            IO.write(v, to: destination + MemoryLayout<Element>.stride * i)
        }
    }
}

extension Array: IO.Writable where Element: IO.Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        for (i, v) in self.enumerated() {
            v.write(to: destination + MemoryLayout<Element>.stride * i)
        }
    }
}
