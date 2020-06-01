//
//  ImageTextAction.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Flow
import Form
import Foundation
import UIKit
import hCore

struct ImageWithOptions {
    let image: UIImage
    let size: CGSize?
    let contentMode: UIView.ContentMode

    init(image: UIImage) {
        self.image = image
        size = nil
        contentMode = .scaleAspectFit
    }

    init(image: UIImage, size: CGSize?, contentMode: UIView.ContentMode) {
        self.image = image
        self.size = size
        self.contentMode = contentMode
    }
}

struct ImageTextAction<ActionResult> {
    let image: ImageWithOptions
    let title: String
    let body: String
    let actions: [(ActionResult, Button)]
    let showLogo: Bool
}

extension ImageTextAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIScrollView, Signal<ActionResult>) {
        let bag = DisposeBag()
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .brand(.primaryBackground())

        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 25, verticalInset: 25)
        containerView.isLayoutMarginsRelativeArrangement = true

        scrollView.embedView(containerView, scrollAxis: .vertical)

        let view = UIStackView()
        view.spacing = 28
        view.axis = .vertical
        view.alignment = .center

        if showLogo {
            let logoImageContainer = UIStackView()
            logoImageContainer.axis = .horizontal
            logoImageContainer.alignment = .center

            let logoImageView = UIImageView()
            logoImageView.image = hCoreUIAssets.wordmark.image
            logoImageView.contentMode = .scaleAspectFit

            logoImageView.snp.makeConstraints { make in
                make.height.equalTo(30)
            }

            logoImageContainer.addArrangedSubview(logoImageView)
            view.addArrangedSubview(logoImageContainer)
        }

        let headerImageContainer = UIStackView()
        headerImageContainer.axis = .horizontal
        headerImageContainer.alignment = .center

        let headerImageView = UIImageView()
        headerImageView.image = image.image
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.tintColor = .brand(.primaryTintColor)

        headerImageView.snp.makeConstraints { make in
            make.height.equalTo(image.size?.height ?? 270)

            if let width = image.size?.width {
                make.width.equalTo(width)
            }
        }

        headerImageContainer.addArrangedSubview(headerImageView)
        view.addArrangedSubview(headerImageContainer)

        let titleLabel = MultilineLabel(
            value: title,
            style: TextStyle.brand(.title1(color: .primary)).aligned(to: .center)
        )
        bag += view.addArranged(titleLabel)

        let bodyLabel = MultilineLabel(
            value: body,
            style: TextStyle.brand(.body(color: .primary)).aligned(to: .center)
        )
        bag += view.addArranged(bodyLabel)

        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 15
        buttonsContainer.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        buttonsContainer.isLayoutMarginsRelativeArrangement = true

        let shadowView = UIView()

        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.1, 0.9, 1]
        shadowView.layer.addSublayer(gradient)

        func setGradientColors() {
            gradient.colors = [
                UIColor.brand(.primaryBackground()).withAlphaComponent(0.2).cgColor,
                UIColor.brand(.primaryBackground()).cgColor,
            ]
        }

        bag += shadowView.traitCollectionSignal.onValue { _ in
            setGradientColors()
        }

        bag += shadowView.didLayoutSignal.onValue { _ in
            gradient.frame = shadowView.bounds
        }

        buttonsContainer.addSubview(shadowView)

        shadowView.snp.makeConstraints { make in
            make.width.height.centerY.centerX.equalToSuperview()
        }

        bag += scrollView.embedPinned(buttonsContainer, edge: .bottom, minHeight: 70)

        containerView.addArrangedSubview(view)

        return (scrollView, Signal { callback in
            bag += self.actions.map { _, button in
                buttonsContainer.addArranged(button.wrappedIn(UIStackView())) { stackView in
                    stackView.axis = .vertical
                    stackView.alignment = .center
                }
            }

            bag += self.actions.map { result, button in
                button.onTapSignal.onValue { _ in
                    callback(result)
                }
            }

            return bag
        })
    }
}
