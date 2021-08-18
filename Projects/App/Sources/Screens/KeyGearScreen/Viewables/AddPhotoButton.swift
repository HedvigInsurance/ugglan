import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct AddPhotoButton { let pickedPhotoSignal = ReadWriteSignal<UIImage?>(nil) }

extension AddPhotoButton: Viewable {
  func materialize(events _: ViewableEvents) -> (UIControl, Signal<UIControl>) {
    let bag = DisposeBag()
    let view = UIControl()
    view.backgroundColor = .brand(.link)
    view.accessibilityLabel = L10n.keyGearAddItemAddPhotoButton

    view.layer.cornerRadius = 8

    view.snp.makeConstraints { make in make.height.equalTo(300) }

    let contentContainer = UIStackView()
    contentContainer.spacing = 8
    contentContainer.axis = .vertical
    contentContainer.alignment = .center
    contentContainer.isUserInteractionEnabled = false

    contentContainer.addArrangedSubview(Icon(icon: Asset.keyGearAddPhoto.image, iconWidth: 40))
    bag += contentContainer.addArranged(
      MultilineLabel(
        value: L10n.keyGearAddItemAddPhotoButton,
        style: TextStyle.brand(.body(color: .primary))
      )
    )

    view.addSubview(contentContainer)

    contentContainer.snp.makeConstraints { make in make.trailing.leading.equalToSuperview()
      make.centerY.equalToSuperview()
    }

    bag += pickedPhotoSignal.atOnce()
      .onValueDisposePrevious { image -> Disposable? in let imageView = UIImageView()
        imageView.image = image
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0

        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
          make.top.bottom.trailing.leading.equalToSuperview()
        }

        let innerBag = DisposeBag()

        innerBag += imageView.didLayoutSignal.take(first: 1)
          .animated(style: AnimationStyle.easeOut(duration: 0.35)) { _ in
            imageView.alpha = 1
          }

        innerBag += DelayedDisposer(Disposer { imageView.removeFromSuperview() }, delay: 2.0)

        return innerBag
      }

    bag += view.signal(for: .touchDown)
      .animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in
        view.backgroundColor = UIColor.brand(.link).darkened(amount: 0.05)
      }

    bag += view.delayedTouchCancel(delay: 0.25)
      .animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in
        view.backgroundColor = .brand(.link)
      }

    return (view, view.trackedTouchUpInsideSignal.hold(bag).map { _ -> UIControl in view })
  }
}
