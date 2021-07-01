import Foundation
import hCore
import Mixpanel

extension AnalyticsProperty {
    var mixpanelType: MixpanelType {
        self as! MixpanelType
    }
}
