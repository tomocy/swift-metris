// tomocy

import Dispatch

extension Shader {
    struct SemaphoricPool<E> {
        private var elements: [Element] = []
        private var semaphore: DispatchSemaphore
        private var userCount: Int = 0
        private var acquireIndex: Int = 0
    }
}

extension Shader.SemaphoricPool {
    typealias Element = E
}

extension Shader.SemaphoricPool {
    init(size: Int, fill: (Int) -> Element) {
        elements.reserveCapacity(size)
        for i in 0..<size {
            elements.append(
                fill(i)
            )
        }

        semaphore = .init(value: size)
        userCount = 0
        acquireIndex = 0
    }
}

extension Shader.SemaphoricPool {
    var size: Int { elements.count }
}

extension Shader.SemaphoricPool {
    mutating func acquire() -> Element {
        semaphore.wait()
        assert(userCount < size)

        let index = acquireIndex
        userCount += 1
        acquireIndex = (acquireIndex + 1) % size

        return elements[index]
    }

    mutating func release() {
        if userCount <= 0 {
            return
        }

        semaphore.signal()
        userCount -= 1
    }
}
