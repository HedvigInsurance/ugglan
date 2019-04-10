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
    static let shared = RemoteConfigContainer()
    private let internalQueue = DispatchQueue(label: String(describing: RemoteConfigContainer.self), qos: .default, attributes: .concurrent)

    private var _remoteConfig: RemoteConfig?
    private var remoteConfig: RemoteConfig {
        get {
            return internalQueue.sync { _remoteConfig! }
        }
        set(newState) {
            internalQueue.async(flags: .barrier) { self._remoteConfig = newState }
        }
    }

    private var _fetched = ReadWriteSignal<Bool>(false)
    var fetched: ReadWriteSignal<Bool> {
        return internalQueue.sync { _fetched }
    }

    init() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let fetchDuration: TimeInterval = 0

        remoteConfig.fetch(withExpirationDuration: fetchDuration, completionHandler: { _, _ in
            remoteConfig.activateFetched()
            self.fetched.value = true
        })

        self.remoteConfig = remoteConfig
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
