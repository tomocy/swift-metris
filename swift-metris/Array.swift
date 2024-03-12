// tomocy

extension Array {
    var size: Int { MemoryLayout<Element>.stride * count }
}

extension Array: Writable where Element: Writable {
    func write(to destination: UnsafeMutableRawPointer) {
        for (i, v) in self.enumerated() {
            v.write(to: destination + MemoryLayout<Element>.stride * i)
        }
    }
}
