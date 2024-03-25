// tomocy

import Foundation

extension Engine {
    struct Log {}
}

extension Engine.Log {
    typealias Details = [(String, String)]

    static func log(_ message: String, with details: Details? = nil) {
        var output = message

        if let details = details {
            output += ": \(serialize(details))"
        }

        NSLog(output)
    }

    private static func serialize(_ details: Details) -> String {
        var output = "{"
        for i in 0..<details.count {
            if i != 0 {
                output += ", "
            }

            let (key, value) = details[i]
            output += "\(key): \(value)"
        }
        output += "}"

        return output
    }
}
