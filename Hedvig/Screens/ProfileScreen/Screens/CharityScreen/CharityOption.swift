//
//  CharityOption.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct CharityOption {
    let id: GraphQLID
    let name: String
    let title: String
    let description: String
    let paragraph: String

    private let onSelectCallbacker = Callbacker<Void>()
    let onSelectSignal: Signal<Void>

    init(
        id: GraphQLID,
        name: String,
        title: String,
        description: String,
        paragraph: String
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.description = description
        self.paragraph = paragraph
        onSelectSignal = onSelectCallbacker.signal()
    }
}

extension CharityOption: Reusable {
    static func makeAndConfigure() -> (make: UIStackView, configure: (CharityOption) -> Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill

        return (stackView, { charityOption in
            stackView.arrangedSubviews.forEach({ view in
                view.removeFromSuperview()
            })

            let bag = DisposeBag()

            let containerView = UIView()

            let contentView = UIStackView()
            contentView.axis = .vertical
            contentView.distribution = .fill
            contentView.spacing = 7.5

            contentView.layoutMargins = UIEdgeInsets(
                top: 15,
                left: 15,
                bottom: 15,
                right: 15
            )
            contentView.isLayoutMarginsRelativeArrangement = true

            containerView.backgroundColor = .white

            let titleLabel = UILabel(
                value: charityOption.name,
                style: .blockRowTitle
            )
            contentView.addArrangedSubview(titleLabel)

            let descriptionLabel = MultilineLabel(
                styledText: StyledText(
                    text: charityOption.description,
                    style: .blockRowDescription
                )
            )
            bag += contentView.addArangedSubview(descriptionLabel)

            bag += contentView.addArangedSubview(Spacing(height: 5))

            let buttonContainer = UIView()

            let button = Button(
                title: "Välj",
                type: .standard(
                    backgroundColor: .purple,
                    textColor: .white
                )
            )

            bag += buttonContainer.add(button) { buttonView in
                bag += button.onTapSignal.onFirstValue {
                    charityOption.onSelectCallbacker.callAll()
                }

                bag += button.onTapSignal.map { _ -> UIView in
                    let testView = UIView()
                    testView.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
                    testView.backgroundColor = .purple
                    testView.layer.cornerRadius = 2.5

                    let activityIndicator = UIActivityIndicatorView()
                    activityIndicator.startAnimating()
                    activityIndicator.style = .whiteLarge

                    testView.addSubview(activityIndicator)

                    activityIndicator.snp.makeConstraints({ make in
                        make.height.equalToSuperview()
                        make.width.equalToSuperview()
                        make.center.equalToSuperview()
                    })

                    let mainWindow = UIApplication.shared.keyWindow!
                    mainWindow.addSubview(testView)

                    let origin = buttonView.convert(
                        CGPoint(x: buttonView.frame.width / 2, y: buttonView.frame.height / 2),
                        to: testView
                    )

                    testView.frame = CGRect(
                        x: origin.x,
                        y: origin.y,
                        width: 5,
                        height: 5
                    )

                    return testView
                }.animated(
                    style: AnimationStyle.easeOut(duration: 0.3)
                ) { testView in
                    let scaleX = (UIScreen.main.bounds.height / testView.frame.width) * 2
                    let scaleY = (UIScreen.main.bounds.height / testView.frame.height) * 2

                    testView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                }.delay(by: 5).animated(style: AnimationStyle.easeOut(duration: 0.25)) { testView in
                    testView.backgroundColor = .white
                }.animated(style: AnimationStyle.easeOut(duration: 0.25)) { testView in
                    testView.alpha = 0
                }.onValue { testView in
                    testView.removeFromSuperview()
                }
            }

            contentView.addArrangedSubview(buttonContainer)

            buttonContainer.snp.makeConstraints { make in
                make.height.equalTo(button.type.height())
            }

            containerView.addSubview(contentView)
            stackView.addArrangedSubview(containerView)

            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            bag += containerView.didLayoutSignal.onValue {
                let shadowPath = UIBezierPath(
                    roundedRect: containerView.bounds,
                    cornerRadius: 16
                )

                containerView.layer.masksToBounds = false
                containerView.layer.cornerRadius = 16
                containerView.layer.shadowOpacity = 1
                containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
                containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
                containerView.layer.shadowRadius = 16
                containerView.layer.shadowPath = shadowPath.cgPath
            }

            return bag
        })
    }
}
