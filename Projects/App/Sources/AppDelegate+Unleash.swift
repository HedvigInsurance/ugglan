import Form
import Presentation
import Profile
import SwiftUI
import UnleashProxyClientSwift
import hCore
import hGraphQL

extension AppDelegate {
    func setupUnleash() {
        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        profileStore.send(.fetchMemberDetails)
        let memberId = profileStore.state.memberDetails?.id ?? ""

        var clientKey: String {
            switch Environment.current {
            case .production:
                return "*:production.21d6af57ae16320fde3a3caf024162db19cc33bf600ab7439c865c20"
            case .custom, .staging:
                return "*:development.f2455340ac9d599b5816fa879d079f21dd0eb03e4315130deb5377b6"
            }
        }

        let environment = clientKey.replacingOccurrences(of: "*:", with: "").components(separatedBy: ".")[0]

        ApplicationContext.shared.unleashClient = UnleashProxyClientSwift.UnleashClient(
            unleashUrl: "https://eu.app.unleash-hosted.com/eubb1047/api/frontend",
            clientKey: clientKey,
            refreshInterval: 15,
            appName: "ios",
            environment: environment,
            context: [
                "memberId": memberId,
                "appVersion": Bundle.main.appVersion,
                "market": Localization.Locale.currentLocale.market.rawValue,
            ]
        )
        startUnleash()
        let unleash = ApplicationContext.shared.unleashClient
        unleash.subscribe(name: "ready", callback: handleReady)
        unleash.subscribe(name: "update", callback: handleUpdate)
    }

    func startUnleash() {
        log.info("Started loading unleash experiments")
        let unleash = ApplicationContext.shared.unleashClient
        unleash.start(
            true,
            completionHandler: { errorResponse in
                guard let errorResponse else {
                    return
                }
                log.info("Failed loading unleash experiments")
            }
        )
    }

    func handleReady() {
        log.info("Successfully loaded unleash experiments")
        DefaultStyling.installCustom()
    }

    func handleUpdate() {
        startUnleash()
    }
}
