import Foundation
import hCoreUI

extension Message {
    @hColorBuilder
    var bgColor: some hColor {
        if case .failed = status {
            hSignalColor.redHighlight
        } else {
            switch self.sender {
            case .hedvig:
                hFillColor.opaqueOne
            case .member:
                hSignalColor.blueFill
            }
        }
    }
    @hColorBuilder
    var textColor: some hColor {
        switch self.sender {
        case .hedvig:
            hTextColor.primary
        case .member:
            hTextColor.primary.colorFor(.light, .elevated)
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
