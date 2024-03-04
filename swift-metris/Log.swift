// tomocy

import Foundation

struct Log {
    typealias Details = [(String, String)]

    static func debug(_ message: String, with details: Details? = nil) {
        var output = ""
        output += message

        if let details = details {
            output += ": \(serializeDetails(details))"
        }

        NSLog(output)
    }

    private static func serializeDetails(_ details: Details) -> String {
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
