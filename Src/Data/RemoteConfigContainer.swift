//
//  RemoteConfigContainer.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Foundation
import FirebaseRemoteConfig

struct RemoteConfigContainer {
    private let remoteConfig: RemoteConfig
    
    init(remoteConfig: RemoteConfig = HedvigApolloClient.shared.remoteConfig!) {
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
