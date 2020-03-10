//
//  RemoteConfigContainer.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import FirebaseRemoteConfig
import Flow
import Foundation

public class RemoteConfigContainer {
    private let remoteConfig: RemoteConfig
    public let fetched: ReadWriteSignal<Bool>

    public init() {
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

    public var referralsWebLandingPrefix: String {
        return remoteConfig.configValue(forKey: "Referrals_WebLanding_Prefix").stringValue ?? ""
    }

    public var keyGearEnabled: Bool {
        remoteConfig.configValue(forKey: "Key_Gear_Enabled").boolValue
    }

    public func referralsEnabled() -> Bool {
        return remoteConfig.configValue(forKey: "Referrals_Enabled").boolValue
    }

    public func referralsIncentive() -> Int {
        return remoteConfig.configValue(
            forKey: "Referrals_Incentive"
        ).numberValue?.intValue ?? 100
    }

    public func dynamicLinkDomainPrefix() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_Domain_Prefix").stringValue ?? ""
    }

    public func dynamicLinkiOSBundleId() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_iOS_BundleId").stringValue ?? ""
    }

    public func dynamicLinkiOSAppStoreId() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_iOS_AppStoreId").stringValue ?? ""
    }

    public func dynamicLinkAndroidPackageName() -> String {
        return remoteConfig.configValue(forKey: "DynamicLink_Android_PackageName").stringValue ?? ""
    }
}
