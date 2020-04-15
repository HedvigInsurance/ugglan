//
//  Bundle+SetLanguage.swift
//  test
//
//  Created by sam on 24.3.20.
//

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

extension Bundle {
    class func setLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: "AppleLanguage")

        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }

        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
