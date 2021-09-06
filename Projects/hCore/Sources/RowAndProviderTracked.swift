import Flow
import Form
import Foundation


extension RowAndProvider {
    public var trackedSignal: CoreSignal<Provider.Kind, Provider.Value> {
        providedSignal.atValue { _ in
            if let derivedFromL10N = self.row.accessibilityLabel?.derivedFromL10n {
                Analytics.track("tap_\(derivedFromL10N.key)", properties: [:])
                Analytics.track("BUTTON_CLICK", properties: [
                    "localizationKey": derivedFromL10N.key
                ])
            }
        }
    }
}
