// tomocy

import Foundation

extension Metris {
    struct Piece {
        func placed(at position: Field.Point) -> Self {
            Self(position: position)
        }

        func append(to primitive: inout IndexedPrimitive) {
            var rect = Rectangle(
                size: CGSize(width: 94, height: 94)
            )

            rect.transform.translate.x = Float(100 * position.x) + 50
            rect.transform.translate.y = Float(100 * position.y) + 50

            rect.append(to: &primitive)
        }

        let position: Field.Point
    }
}
