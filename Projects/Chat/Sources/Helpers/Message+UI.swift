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

    var padding: CGFloat {
        switch type {
        case .text:
            return 16
        default:
            return 0
        }
    }
}
