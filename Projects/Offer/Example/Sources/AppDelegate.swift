import ExampleUtil
import Flow
import Form
import Foundation
import UIKit
import hCoreUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  let bag = DisposeBag()

  internal func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    application.setup()

    return true
  }
}
