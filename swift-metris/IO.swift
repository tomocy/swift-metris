// tomocy

enum IO {
    typealias Writable = _Writable
}

protocol _Writable {
    func write(to destination: UnsafeMutableRawPointer)
}
