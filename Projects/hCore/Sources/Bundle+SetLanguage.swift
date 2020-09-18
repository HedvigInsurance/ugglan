import Foundation
import UIKit

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

public extension Bundle {
    class func setLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: "AppleLanguage")

        defer {
            object_setClass(Bundle(for: AnyLanguageBundle.self), AnyLanguageBundle.self)
        }

        objc_setAssociatedObject(Bundle(for: AnyLanguageBundle.self), &bundleKey, Bundle(for: AnyLanguageBundle.self).path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
