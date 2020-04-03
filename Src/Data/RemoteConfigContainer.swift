//
//  RemoteConfigContainer.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import FirebaseRemoteConfig
import Flow
import Foundation

class RemoteConfigContainer {
    private let remoteConfig: RemoteConfig
    let fetched: ReadWriteSignal<Bool>

    init() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let fetched = ReadWriteSignal<Bool>(false)

        self.fetched = fetched
        self.remoteConfig = remoteConfig

        fetch(false)
    }

    func fetch(_ force: Bool) {
        #if DEBUG
            let fetchDuration: TimeInterval = 0
        #else
            let fetchDuration: TimeInterval = force ? 0 : 3600
        #endif

        remoteConfig.fetch(withExpirationDuration: fetchDuration, completionHandler: { _, _ in
            self.remoteConfig.activate(completionHandler: { _ in
                self.fetched.value = true
            })
        })
    }

    var referralsWebLandingPrefix: String {
        return remoteConfig.configValue(forKey: "Referrals_WebLanding_Prefix").stringValue ?? ""
    }

    var keyGearEnabled: Bool {
        remoteConfig.configValue(forKey: "Key_Gear_Enabled").boolValue
    }

    func referralsEnabled() -> Bool {
        return remoteConfig.configValue(forKey: "Referrals_Enabled").boolValue
    }

    func referralsIncentive() -> Int {
        return remoteConfig.configValue(
            forKey: "Referrals_Incentive"
        ).numberValue?.intValue ?? 100
    }

    func dynamicLinkDomainPrefix() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_Domain_Prefix").stringValue ?? ""
    }

    func dynamicLinkiOSBundleId() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_iOS_BundleId").stringValue ?? ""
    }

    func dynamicLinkiOSAppStoreId() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_iOS_AppStoreId").stringValue ?? ""
    }

    func dynamicLinkAndroidPackageName() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_Android_PackageName").stringValue ?? ""
    }
}
