import Environment
import Foundation
import UIKit
@preconcurrency import HedvigShared
import hGraphQL

class IosDeviceIdFetcher: DeviceIdFetcher {
    func fetch() async throws -> String? {
        return await UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}

class IosAppBuildConfig: AppBuildConfig {
    var appFlavor: Flavor = {
        switch Environment.current {
        case .production: return .production
        case .staging, .custom: return .staging
        }
    }()
    var applicationId: String = Bundle.main.bundleIdentifier ?? ""
    var brand: String = "hedvig"
    var buildType: String = {
        #if DEBUG
        return "debug"
        #else
        return "release"
        #endif
    }()
    var debug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    var device: String = "UIDevice.current.model"
    var manufacturer: String = "Apple"
    var model: String = "UIDevice.current.model"
    var osReleaseVersion: String = "UIDevice.current.systemVersion"
    var osSdkVersion: Int32 = 0
    var versionCode: Int32 = Int32(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
    var versionName: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
}
