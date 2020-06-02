import Foundation
import UIKit
import Forever
import Flow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        bag += navigationController.present(Debug())
        
        return true
    }
}
