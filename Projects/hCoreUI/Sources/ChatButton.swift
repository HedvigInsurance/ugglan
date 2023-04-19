import Flow
import Foundation
import UIKit
import hCore

public struct ChatButton {
    public static var openChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
    public let presentingViewController: UIViewController
    public let allowsChatHint: Bool

    public init(
        presentingViewController: UIViewController,
        allowsChatHint: Bool = false
    ) {
        self.presentingViewController = presentingViewController
        self.allowsChatHint = allowsChatHint
    }
}
