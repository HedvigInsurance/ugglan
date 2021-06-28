import Flow
import Forever
import Form
import Foundation
import UIKit
import hCoreUI

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	let bag = DisposeBag()

	internal func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		application.setup()
		window = UIWindow(frame: UIScreen.main.bounds)

		let navigationController = UINavigationController()
		navigationController.navigationBar.prefersLargeTitles = true

		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()

		bag += navigationController.present(
			Debug(),
			style: .default,
			options: [.largeTitleDisplayMode(.always)]
		)

		return true
	}
}
