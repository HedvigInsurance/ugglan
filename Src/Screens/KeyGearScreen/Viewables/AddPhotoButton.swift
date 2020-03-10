//
//  AddPhotoButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-10.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct AddPhotoButton {
    let pickedPhotoSignal = ReadWriteSignal<UIImage?>(nil)
}

extension AddPhotoButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<UIControl>) {
        let bag = DisposeBag()
        let view = UIControl()
        view.backgroundColor = .secondaryTintColor
        view.accessibilityLabel = String(key: .KEY_GEAR_ADD_ITEM_ADD_PHOTO_BUTTON)

        view.layer.cornerRadius = 8

        view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }

        let contentContainer = UIStackView()
        contentContainer.spacing = 8
        contentContainer.axis = .vertical
        contentContainer.alignment = .center
        contentContainer.isUserInteractionEnabled = false

        contentContainer.addArrangedSubview(Icon(icon: Asset.keyGearAddPhoto.image, iconWidth: 40))
        bag += contentContainer.addArranged(MultilineLabel(value: String(key: .KEY_GEAR_ADD_ITEM_ADD_PHOTO_BUTTON), style: TextStyle.body.colored(.primaryTintColor)))

        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        bag += pickedPhotoSignal.atOnce().onValueDisposePrevious { image -> Disposable? in
            let imageView = UIImageView()
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

            innerBag += imageView.didLayoutSignal.take(first: 1).animated(style: AnimationStyle.easeOut(duration: 0.35)) { _ in
                imageView.alpha = 1
            }

            innerBag += DelayedDisposer(Disposer {
                imageView.removeFromSuperview()
            }, delay: 2.0)

            return innerBag
        }

        bag += view.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in
            view.backgroundColor = UIColor.secondaryTintColor.darkened(amount: 0.05)
        }

        bag += view.delayedTouchCancel(delay: 0.25).animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in
            view.backgroundColor = .secondaryTintColor
        }

        return (view, view.trackedTouchUpInsideSignal.hold(bag).map { _ -> UIControl in view })
    }
}
