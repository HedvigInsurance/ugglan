import Flow
import Foundation

extension Either: Codable where Left: Codable, Right: Codable {
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        if let left = try? container.decode(Left.self) {
            self = .left(left)
        } else if let right = try? container.decode(Right.self) {
            self = .right(right)
        } else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Could not decode either left or right",
                    underlyingError: nil
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let left = left {
            return try left.encode(to: encoder)
        } else if let right = right {
            return try right.encode(to: encoder)
        }
    }
}
