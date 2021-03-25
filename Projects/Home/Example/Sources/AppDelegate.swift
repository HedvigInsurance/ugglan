import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    func run() {
        window = UIWindow(frame: UIScreen.main.bounds)

        DefaultStyling.installCustom()

        Localization.Locale.currentLocale = .en_SE

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTouchesRequired = 3

        bag += tapGestureRecognizer.signal(forState: .recognized).onValue { _ in
            self.bag.dispose()
            self.run()
        }

        window?.addGestureRecognizer(tapGestureRecognizer)

        bag += {
            self.window?.removeGestureRecognizer(tapGestureRecognizer)
        }

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
    }

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        run()
        return true
    }
}
