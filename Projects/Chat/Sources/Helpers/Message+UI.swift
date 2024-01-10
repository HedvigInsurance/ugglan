import Foundation
import hCoreUI

extension Message {
    @hColorBuilder
    var bgColor: some hColor {
        switch self.sender {
        case .hedvig:
            hFillColor.opaqueOne
        case .member:
            hSignalColor.blueFill
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

    var padding: CGFloat {
        switch type {
        case .text:
            return 16
        default:
            return 0
        }
    }
}
