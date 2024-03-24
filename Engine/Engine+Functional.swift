// tomocy

extension Engine {
    struct Functional<V> {
        var generate: Generator
    }
}

extension Engine.Functional {
    typealias Value = V
    typealias Generator = () -> Value
}

extension Engine.Functional {
    init(_ value: Value) {
        self.init(
            generate: { value }
        )
    }
}

extension Engine.Functional {
    func state(_ apply: @escaping (inout Value) -> Void) -> Self {
        return .init(
            generate: {
                var state = self.generate()
                apply(&state)
                return state
            }
        )
    }
}
