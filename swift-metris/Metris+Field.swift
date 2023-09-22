// tomocy

extension Metris {
    struct Field {
        init(width: UInt, height: UInt) {
            self.width = width
            self.height = height

            raw = .init(repeating: false, count: Int(width * height))
            for y in 0..<height {
                for x in 0..<width {
                    set(x: x, y: y, index(x: x, y: y) % 2 == 0)
                }
            }
        }

        func index(x: UInt, y: UInt) -> Int {
            Int(y * width + x)
        }

        func get(x: UInt, y: UInt) -> Bool {
            raw[index(x: x, y: y)]
        }

        mutating func set(x: UInt, y: UInt, _ v: Bool) {
            raw[index(x: x, y: y)] = v
        }

        let width: UInt
        let height: UInt
        private var raw: [Bool] = []
    }
}
