// tomocy

import Dispatch

struct SemaphoricPool<Element> {
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

    var size: Int { elements.count }

    private var elements: [Element] = []
    private var semaphore: DispatchSemaphore
    private var userCount: Int = 0
    private var acquireIndex: Int = 0
}
