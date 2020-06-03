import Flow
import Forever
import Form
import Foundation
import hCoreUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    internal func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DefaultStyling.installCustom()

        window = UIWindow(frame: UIScreen.main.bounds)

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        bag += navigationController.present(Debug(), style: .default, options: [.largeTitleDisplayMode(.always)])

        return true
    }
}
