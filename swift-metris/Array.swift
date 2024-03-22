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

extension Array: Primitive.Primitive where Element: Primitive.Primitive {
    typealias Vertex = Element.Vertex
}

extension Array: IndexedPrimitive.Projectable where Element: IndexedPrimitive.Projectable {
    func project(beside primitive: IndexedPrimitive<Vertex>) -> IndexedPrimitive<Vertex> {
        var result = IndexedPrimitive<Vertex>.init()

        forEach { v in
            result.append(
                v.project(beside: primitive.appent(result))
            )
        }

        return result
    }
}

extension Array: IndexedPrimitive.Appendable where Element: IndexedPrimitive.Appendable {
    func append(to primitive: inout IndexedPrimitive<Vertex>) {
        forEach { $0.append(to: &primitive) }
    }
}
