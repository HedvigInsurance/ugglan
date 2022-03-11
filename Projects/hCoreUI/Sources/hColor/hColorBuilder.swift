import Foundation
import SwiftUI

public struct EitherHColor<Left: hColor, Right: hColor>: hColor {
    enum Storage {
        case left(value: Left)
        case right(value: Right)
    }

    var storage: Storage

    public var inverted: some hColor {
        switch storage {
        case let .left(value):
            return EitherHColor<Left.Inverted, Right.Inverted>(left: value.inverted)
        case let .right(value):
            return EitherHColor<Left.Inverted, Right.Inverted>(right: value.inverted)
        }
    }

    public func opacity(_ opacity: Double) -> some hColor {
        switch storage {
        case let .left(value):
            return EitherHColor<Left.OpacityModified, Right.OpacityModified>(left: value.opacity(opacity))
        case let .right(value):
            return EitherHColor<Left.OpacityModified, Right.OpacityModified>(right: value.opacity(opacity))
        }
    }

    public func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase {
        switch storage {
        case let .left(value):
            return value.colorFor(scheme, level)
        case let .right(value):
            return value.colorFor(scheme, level)
        }
    }

    init(
        left: Left
    ) {
        self.storage = .left(value: left)
    }

    init(
        right: Right
    ) {
        self.storage = .right(value: right)
    }

    public var body: some View {
        switch storage {
        case let .left(value):
            value
        case let .right(value):
            value
        }
    }
}

@resultBuilder
public struct hColorBuilder {
    public static func buildBlock<Color: hColor>(_ color: Color) -> some hColor {
        return color
    }

    public static func buildEither<Left: hColor, Right: hColor>(first color: Left) -> EitherHColor<Left, Right> {
        EitherHColor(left: color)
    }

    public static func buildEither<Left: hColor, Right: hColor>(second color: Right) -> EitherHColor<Left, Right> {
        EitherHColor(right: color)
    }
}
