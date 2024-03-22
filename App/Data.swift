// tomocy

struct Indexed<T> {
    var data: T
    var index: T
}

extension Indexed: Equatable where T: Equatable {
    static func ==(left: Self, right: Self) -> Bool {
        return left.data == right.data
            && left.index == right.index
    }
}

extension Indexed: AdditiveArithmetic where T: AdditiveArithmetic {
    static var zero: Self {
        .init(data: .zero, index: .zero)
    }

    static func +(left: Self, right: Self) -> Self {
        return .init(
            data: left.data + right.data,
            index: left.index + right.index
        )
    }

    static func -(left: Self, right: Self) -> Self {
        return .init(
            data: left.data - right.data,
            index: left.index - right.index
        )
    }
}
