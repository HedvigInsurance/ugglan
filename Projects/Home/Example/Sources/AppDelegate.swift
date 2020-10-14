import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        DefaultStyling.installCustom()

        Localization.Locale.currentLocale = .en_SE

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        Dependencies.shared.add(module: Module {
            ApolloEnvironmentConfig(
                endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
                wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
                assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
            )
        })

        navigationController.present(
            Debug(),
            options: [
                .defaults,
                .largeTitleDisplayMode(.always),
            ]
        )

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        ApplicationContext.shared.hasFinishedBootstrapping = true

        return true
    }
}
