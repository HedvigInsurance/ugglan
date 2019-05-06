//
//  ClaimsHeader.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-04-23.
//

import Flow
import Form
import Foundation
import UIKit

struct ClaimsHeader {
    let presentingViewController: UIViewController

    struct Title {}
    struct Description {}
}

extension ClaimsHeader.Title: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()

        let label = MultilineLabel(
            value: String(key: .CLAIMS_HEADER_TITLE),
            style: TextStyle.standaloneLargeTitle.centered()
        )

        bag += view.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(10)
                make.width.equalToSuperview().multipliedBy(0.7)
            }
        }

        return (view, bag)
    }
}

extension ClaimsHeader.Description: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()

        let label = MultilineLabel(
            value: String(key: .CLAIMS_HEADER_SUBTITLE),
            style: TextStyle.body.centered()
        )

        bag += view.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.7)
            }
        }

        return (view, bag)
    }
}

extension ClaimsHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()

        let imageView = UIImageView()
        imageView.image = Asset.claimsHeader.image

        imageView.snp.makeConstraints { make in
            make.height.equalTo(185)
        }

        view.addArrangedSubview(imageView)

        let title = Title()
        bag += view.addArranged(title)

        let description = Description()
        bag += view.addArranged(description)

        let button = Button(title: String(key: .CLAIMS_HEADER_ACTION_BUTTON), type: .standard(backgroundColor: .purple, textColor: .white))

        bag += button.onTapSignal.onValue {
            self.presentingViewController.present(
                DraggableOverlay(
                    presentable: HonestyPledge(),
                    presentationOptions: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .prefersNavigationBarHidden(true)],
                    heightPercentage: 0.40
                )
            )
        }

        bag += view.addArranged(button.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        return (view, bag)
    }
}
