// tomocy

import Foundation

extension Metris {
    struct Ticker {
        let interval: TimeInterval
        private var raw: Timer?
    }
}

extension Metris.Ticker {
    init(interval: TimeInterval) {
        self.interval = interval
    }
}

extension Metris.Ticker {
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
}
