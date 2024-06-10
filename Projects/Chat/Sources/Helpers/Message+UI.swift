import Foundation
import hCoreUI

extension Message {
    @hColorBuilder
    var bgColor: some hColor {
        if case .failed = status {
            hSignalColor.Red.highlight
        } else {
            switch self.sender {
            case .hedvig:
                hSurfaceColor.Opaque.primary
            case .member:
                hSignalColor.Blue.fill
            }
        }
    }
    @hColorBuilder
    var textColor: some hColor {
        switch self.sender {
        case .hedvig:
            hTextColor.Opaque.primary
        case .member:
            hTextColor.Opaque.primary.colorFor(.light, .elevated)
        }
    }

    var horizontalPadding: CGFloat {
        switch type {
        case .text, .deepLink:
            return 16
        default:
            return 0
        }
    }
    var verticalPadding: CGFloat {
        switch type {
        case .text, .deepLink:
            return 12
        default:
            return 0
        }
    }
}
