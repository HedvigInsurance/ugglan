import Foundation
import UIKit

public protocol TranslationArgumentable { var value: CVarArg { get } }

extension String: TranslationArgumentable { public var value: CVarArg { self } }

extension Int: TranslationArgumentable { public var value: CVarArg { self } }

public struct L10nDerivation {
    public let table: String
    public let key: String
    public let args: [TranslationArgumentable]

    /// render the text key again, useful if you have changed the language during runtime
    public func render() -> String { L10n.tr(table, key, args) }
}

extension String {
    public static var derivedFromL10n: UInt8 = 0

    /// set when String is derived from a L10n key
    public var derivedFromL10n: L10nDerivation? {
        get {
            guard let value = objc_getAssociatedObject(self, &String.derivedFromL10n) as? L10nDerivation?
            else { return nil }

            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &String.derivedFromL10n,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
