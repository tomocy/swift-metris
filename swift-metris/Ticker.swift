// tomocy

import Foundation

struct Ticker {
    init(interval: TimeInterval) {
        self.interval = interval
    }

    mutating func start(_ fn: @escaping () -> Void) {
        assert(raw == nil)
        raw = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            fn()
        }
    }

    mutating func stop() {
        raw?.invalidate()
        raw = nil
    }

    let interval: TimeInterval
    private var raw: Timer?
}
