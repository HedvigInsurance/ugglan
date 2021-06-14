import Contracts
import Flow
import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navController = UINavigationController()
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        let flow = MovingFlowIntro()
        flow.$sections.value = .manual

        navController.present(flow)

        return true
    }
}
