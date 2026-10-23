import Environment
import Foundation

enum BankIDSandboxState {
    private static let storageKey = "bankid_sandbox_enabled"

    static var isAvailable: Bool { Environment.current == .staging }

    // isAvailable is ANDed into the getter so a value left behind in defaults can never
    // reach a production request after an environment switch.
    static var isEnabled: Bool {
        get { isAvailable && UserDefaults.standard.bool(forKey: storageKey) }
        set { UserDefaults.standard.set(newValue, forKey: storageKey) }
    }
}
