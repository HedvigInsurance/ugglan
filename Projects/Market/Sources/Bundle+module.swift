import Foundation


private class BundleFinder {}

extension Foundation.Bundle {
    /// Since Market is a framework, the bundle for classes within this module can be used directly.
    static let module = Bundle(for: BundleFinder.self)
}
