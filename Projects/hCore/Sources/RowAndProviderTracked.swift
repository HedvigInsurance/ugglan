import Flow
import Form
import Foundation

public enum RowAndProviderTracking {
    public static var handler: (_ name: String) -> Void = { _ in }
}

public extension RowAndProvider {
    var trackedSignal: CoreSignal<Provider.Kind, Provider.Value> {
        providedSignal.atValue { _ in
            if let derivedFromL10N = self.row.accessibilityLabel?.derivedFromL10n {
                RowAndProviderTracking.handler("tap_\(derivedFromL10N.key)")
            }
        }
    }
}
