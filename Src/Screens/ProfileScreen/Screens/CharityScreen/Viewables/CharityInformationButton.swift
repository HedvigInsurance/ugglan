//
//  CharityInformationButton.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-04-04.
//

import Flow
import Foundation
import SnapKit
import UIKit

struct CharityInformationButton {
    let presentingViewController: UIViewController

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
}

extension CharityInformationButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()

        let bag = DisposeBag()

        let button = Button(
            title: String(key: .PROFILE_MY_CHARITY_INFO_BUTTON),
            type: .iconTransparent(textColor: .purple, icon: .left(image: Asset.infoPurple.image, width: 20))
        )

        bag += view.add(button) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        bag += button.onTapSignal.onValue { _ in
            self.presentingViewController.present(
                DraggableOverlay(
                    presentable: CharityInformation(),
                    presentationOptions: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .prefersNavigationBarHidden(true)]
                )
            )
        }

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(button.type.value.height)
        }

        return (view, bag)
    }
}
