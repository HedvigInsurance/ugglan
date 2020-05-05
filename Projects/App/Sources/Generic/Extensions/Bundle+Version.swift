//
//  Bundle+Version.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-11.
//

import Foundation

extension Bundle {
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
}
