import SwiftUI
import hCore

public enum hRadioIndicatorPlacement: Hashable, Sendable {
    case leading
    case trailing
}

public enum hRadioOptionAccessory: Hashable, Sendable {
    case radio
    case chevron
    case none
}

public enum hRadioOptionListAxis: Hashable, Sendable {
    case vertical
    case horizontal
}

extension EnvironmentValues {
    @Entry public var hRadioIndicatorPlacement: hRadioIndicatorPlacement = .trailing

    @Entry var hRadioOptionListAxis: hRadioOptionListAxis? = nil

    @Entry var hRadioOptionListSpacing: CGFloat = 0
}

extension View {
    public func hRadioIndicatorPlacement(_ placement: hRadioIndicatorPlacement) -> some View {
        environment(\.hRadioIndicatorPlacement, placement)
    }
}

struct hRadioOptionMetrics {
    let size: hFieldSize

    init(_ size: hFieldSize) {
        self.size = size
    }

    var titleStyle: HFontTextStyle {
        switch size {
        case .large, .extraLarge:
            return .body2
        case .medium, .small:
            return .body1
        }
    }

    var minHeight: CGFloat {
        switch size {
        case .small:
            return 56
        case .medium, .large, .extraLarge:
            return 64
        }
    }

    var topPadding: CGFloat {
        switch size {
        case .small:
            return 15
        case .large:
            return 16
        case .medium:
            return 19
        case .extraLarge:
            return 20
        }
    }

    var bottomPadding: CGFloat {
        topPadding + 2
    }

    /// A 40pt icon is taller than the text line, so icon rows inset less.
    var iconVerticalPadding: CGFloat {
        8
    }

    /// Small icon rows pull in 2pt so the icon lines up with neighbouring rows' text.
    func leadingPadding(hasIcon: Bool) -> CGFloat {
        (hasIcon && size == .small) ? .padding12 : size.horizontalPadding
    }

    var horizontalPadding: CGFloat {
        size.horizontalPadding
    }

    var labelTopPadding: CGFloat {
        size == .small ? .padding10 : .padding12
    }

    var spacing: CGFloat {
        .padding8
    }

    var iconSize: CGFloat {
        40
    }
}
