import Flow
import Form
import Foundation
import UIKit
import hCore

struct CircleLabel {
  let labelText: DynamicString
  let backgroundColor: UIColor?
  let textColor: UIColor?

  init(
    labelText: DynamicString,
    backgroundColor: UIColor? = .lightGray,
    textColor: UIColor? = .white
  ) {
    self.labelText = labelText
    self.backgroundColor = backgroundColor
    self.textColor = textColor
  }
}

extension CircleLabel: Viewable {
  func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
    let view = UIView()
    let bag = DisposeBag()

    let label = UILabel()
    bag += label.setDynamicText(labelText)

    label.clipsToBounds = true
    label.textAlignment = .center
    label.font = HedvigFonts.favoritStdBook?.withSize(30)
    label.textColor = textColor
    label.numberOfLines = 3
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.1

    let labelContainer = UIView()
    labelContainer.backgroundColor = backgroundColor

    bag += labelContainer.applyShadow { _ in
      UIView.ShadowProperties(
        opacity: 0.2,
        offset: CGSize(width: 10, height: 10),
        blurRadius: 3,
        color: UIColor.brand(.primaryShadowColor),
        path: nil,
        radius: 16
      )
    }

    labelContainer.addSubview(label)

    bag += labelContainer.didLayoutSignal.onValue { _ in
      labelContainer.layer.cornerRadius = labelContainer.frame.height * 0.5
    }

    bag += label.didLayoutSignal.onValue { _ in
      label.snp.remakeConstraints { make in make.width.equalToSuperview().inset(20)
        make.height.equalToSuperview().inset(20)
        make.center.equalToSuperview()
      }
    }

    view.addSubview(labelContainer)

    labelContainer.snp.makeConstraints { make in make.height.width.equalTo(view.snp.height)
      make.center.equalToSuperview()
    }

    bag += view.didMoveToWindowSignal.onValue { _ in
      view.snp.makeConstraints { make in make.width.equalToSuperview()
        make.height.equalToSuperview()
        make.center.equalToSuperview()
      }
    }

    return (view, bag)
  }
}
