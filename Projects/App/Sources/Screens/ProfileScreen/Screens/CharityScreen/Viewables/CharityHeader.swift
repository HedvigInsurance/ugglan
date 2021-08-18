import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct CharityHeader {}

extension CharityHeader: Viewable {
  func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
    let bag = DisposeBag()
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 15
    stackView.isLayoutMarginsRelativeArrangement = true

    bag += stackView.traitCollectionSignal.atOnce()
      .onValue { trait in let style = DynamicFormStyle.brandInset.style(from: trait)
        let insets = style.insets
        stackView.layoutMargins = UIEdgeInsets(
          top: insets.top,
          left: insets.left,
          bottom: 24,
          right: insets.right
        )
      }

    let icon = Icon(frame: .zero, icon: Asset.charityPlain.image, iconWidth: 40)
    stackView.addArrangedSubview(icon)

    let multilineLabel = MultilineLabel(
      styledText: StyledText(
        text: L10n.charityScreenHeaderMessage,
        style: TextStyle.brand(.body(color: .primary)).centerAligned
      )
    )

    bag += stackView.addArranged(multilineLabel)

    return (stackView, bag)
  }
}
