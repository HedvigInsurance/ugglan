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

    private let remoteConfig: RemoteConfig
    let fetched: ReadWriteSignal<Bool>

    init() {
        let remoteConfig = RemoteConfig.remoteConfig()

        #if DEBUG
            let fetchDuration: TimeInterval = 0
        #else
            let fetchDuration: TimeInterval = 3600
        #endif

        let fetched = ReadWriteSignal<Bool>(false)

        self.fetched = fetched

        remoteConfig.fetch(withExpirationDuration: fetchDuration, completionHandler: { _, _ in
            remoteConfig.activateFetched()
            fetched.value = true
        })
        
        self.remoteConfig = remoteConfig
        
        let bag = DisposeBag()
        
        bag += fetched.onValue { _ in
            self.chatPreviewEnabledSignal.value = remoteConfig.configValue(forKey: "Chat_Preview_Enabled").boolValue
        }
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
    
    let chatPreviewEnabledSignal = ReadWriteSignal(false)
}
