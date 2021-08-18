import Flow
import Foundation
import Presentation
import UIKit

struct ChatPresentationStyle {
  static let style = PresentationStyle(name: "chat") {
    (viewController, presentingViewController, _) -> PresentationStyle.Result in

    let (present, dismiss) = PresentationStyle.default.present(
      viewController,
      from: presentingViewController,
      options: [.defaults, .prefersNavigationBarHidden(false)]
    )

    if let navigationBar = presentingViewController.navigationController?.navigationBar {
      navigationBar.isHidden = false
      navigationBar.barStyle = .default
    }

    return (present, dismiss)
  }
}

extension PresentationStyle { static let chat = ChatPresentationStyle.style }
