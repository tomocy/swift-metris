// tomocy

import Foundation

extension MetrisX {
    struct Ticker {
        let interval: TimeInterval
        private var raw: Timer?
    }
}

extension MetrisX.Ticker {
    init(interval: TimeInterval) {
        self.interval = interval
    }
}

extension MetrisX.Ticker {
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
