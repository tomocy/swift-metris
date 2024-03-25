// tomocy

extension Array {
    var size: Int { MemoryLayout<Element>.stride * count }
}
