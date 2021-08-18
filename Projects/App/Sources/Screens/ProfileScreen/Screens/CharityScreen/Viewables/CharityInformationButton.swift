import Flow
import Foundation
import SnapKit
import UIKit
import hCore
import hCoreUI

struct CharityInformationButton {
  let presentingViewController: UIViewController

  init(presentingViewController: UIViewController) { self.presentingViewController = presentingViewController }
}

extension CharityInformationButton: Viewable {
  func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
    let view = UIView()

    let bag = DisposeBag()

    let button = Button(
      title: L10n.profileMyCharityInfoButton,
      type: .iconTransparent(
        textColor: .brand(.primaryTintColor),
        icon: .left(image: hCoreUIAssets.infoSmall.image, width: .smallIconWidth)
      )
    )

    bag += view.add(button) { buttonView in
      buttonView.snp.makeConstraints { make in make.center.equalToSuperview() }
    }

    bag += button.onTapSignal.onValue { _ in
      self.presentingViewController.present(
        CharityInformation().wrappedInCloseButton(),
        style: .detented(.medium, .large),
        options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
      )
    }

    bag += view.didLayoutSignal.onFirstValue {
      view.snp.makeConstraints { make in make.height.equalTo(button.type.value.height) }
    }

    return (view, bag)
  }
}
