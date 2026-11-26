import TravelCertificateCore
import hCoreUI

extension TravelCertificateModel {
    @hColorBuilder
    var textColor: some hColor {
        if valid {
            hTextColor.Opaque.primary
        } else {
            hSignalColor.Red.element
        }
    }
}
