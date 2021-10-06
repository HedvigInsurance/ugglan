import Foundation
import Mixpanel
import hCore

extension AnalyticsProperty {
    var mixpanelType: MixpanelType {
        self as! MixpanelType
    }
}
