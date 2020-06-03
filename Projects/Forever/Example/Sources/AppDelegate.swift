import Foundation
import UIKit
import Forever
import Flow
import hCoreUI
import Form

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DefaultStyling.installCustom()
                
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        bag += navigationController.present(Debug(), style: .default, options: [.largeTitleDisplayMode(.always)])
        
        return true
    }
}
