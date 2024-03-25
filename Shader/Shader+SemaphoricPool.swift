// tomocy

import Dispatch

extension Shader {
    class SemaphoricPool<E> {
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
    var size: Int { elements.count }
}

extension Shader.SemaphoricPool {
    func acquire() -> Element {
        semaphore.wait()
        assert(userCount < size)

        let index = acquireIndex
        userCount += 1
        acquireIndex = (acquireIndex + 1) % size

        return elements[index]
    }

    func release() {
        if userCount <= 0 {
            return
        }

        semaphore.signal()
        userCount -= 1
    }
}
