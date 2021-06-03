import Flow
import Foundation
import UIKit

public enum CrossFramework {
	public static var presentLogin: (_ viewController: UIViewController) -> Void = { _ in }
	public static var presentOnboarding: (_ viewController: UIViewController) -> Void = { _ in }
	public static var onRequestLogout: () -> Void = {}
}
