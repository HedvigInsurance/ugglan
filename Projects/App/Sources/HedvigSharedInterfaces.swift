import Apollo
import Environment
import Foundation
@preconcurrency import HedvigShared
import UIKit
import hCore
import hGraphQL

class IosDeviceIdFetcher: DeviceIdFetcher {
    func fetch() async throws -> String? {
        await ApolloClient.getDeviceIdentifier()
    }
}

class IosLanguageStorage: LanguageStorage {
    func getCurrentLanguageTag() -> String {
        Localization.Locale.currentLocale.value.lprojCode
    }

    func getSelectedLanguageTag() -> String? {
        Localization.Locale.currentLocale.value.lprojCode
    }

    func setLanguageTag(tag: String) {
        let locale: Localization.Locale = (tag == Localization.Locale.sv_SE.lprojCode) ? .sv_SE : .en_SE
        Task {
            await ApplicationState.setPreferredLocale(locale)
            Localization.Locale.currentLocale.send(locale)
        }
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
    var device: String
    var manufacturer: String = "Apple"
    var model: String
    var osReleaseVersion: String
    var osSdkVersion: Int32 = 0
    var versionCode: Int32 = Bundle.main.buildVersion
    var versionName: String = Bundle.main.appVersion

    @MainActor
    init() {
        self.device = UIDevice.current.model
        self.model = UIDevice.modelName
        self.osReleaseVersion = UIDevice.current.systemVersion
    }
}
