//
//  RemoteConfigContainer.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

// import FirebaseRemoteConfig
import Flow
import Foundation

class RemoteConfigContainer {
    //private let remoteConfig: RemoteConfig
    let fetched: ReadWriteSignal<Bool>

    init() {
        // let remoteConfig = RemoteConfig.remoteConfig()
        let fetched = ReadWriteSignal<Bool>(true)

        self.fetched = fetched
        // self.remoteConfig = remoteConfig

        fetch(false)
    }

    func fetch(_ force: Bool) {
        #if DEBUG
            let fetchDuration: TimeInterval = 0
        #else
            let fetchDuration: TimeInterval = force ? 0 : 3600
        #endif
        
        let bag = DisposeBag()
        
        bag += Signal(after: 0.5).onValue { _ in
            self.fetched.value = true
            bag.dispose()
        }
        
//
//        remoteConfig.fetch(withExpirationDuration: fetchDuration, completionHandler: { _, _ in
//            self.remoteConfig.activate(completionHandler: { _ in
//                self.fetched.value = true
//            })
//        })
    }

    var referralsWebLandingPrefix: String {
        return ""
    }

    var keyGearEnabled: Bool {
        true
    }

    func referralsEnabled() -> Bool {
        return true
    }

    func referralsIncentive() -> Int {
        return 100
    }

    func dynamicLinkDomainPrefix() -> String {
        return ""
    }

    func dynamicLinkiOSBundleId() -> String {
        return ""
    }

    func dynamicLinkiOSAppStoreId() -> String {
        return ""
    }

    func dynamicLinkAndroidPackageName() -> String {
        return ""
    }
}
