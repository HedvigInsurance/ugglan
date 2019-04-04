//
//  SelectedCharity.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-23.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct SelectedCharity {
    let client: ApolloClient
    let animateEntry: Bool
    let presentingViewController: UIViewController

    init(
        client: ApolloClient = ApolloContainer.shared.client,
        animateEntry: Bool,
        presentingViewController: UIViewController
    ) {
        self.client = client
        self.animateEntry = animateEntry
        self.presentingViewController = presentingViewController
    }
}

extension SelectedCharity: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.edgeInsets = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )
        stackView.isLayoutMarginsRelativeArrangement = true

        scrollView.addSubview(stackView)

        bag += client.watch(query: SelectedCharityQuery()).compactMap { $0.data?.cashback }.onValue { cashback in
            for subview in stackView.arrangedSubviews {
                subview.removeFromSuperview()
            }
            
            let charityLogo = CharityLogo(url: cashback.imageUrl!)
            bag += stackView.addArangedSubview(charityLogo) { view in
                view.snp.makeConstraints { make in
                    make.height.equalTo(190)
                }
            }

            let infoContainer = UIView()
            infoContainer.backgroundColor = .white
            infoContainer.layer.cornerRadius = 8
            infoContainer.layer.shadowOpacity = 0.2
            infoContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
            infoContainer.layer.shadowRadius = 16
            infoContainer.layer.shadowColor = UIColor.darkGray.cgColor

            let infoContainerStackView = UIStackView()
            infoContainerStackView.axis = .vertical
            infoContainerStackView.spacing = 5
            infoContainerStackView.edgeInsets = UIEdgeInsets(
                top: 24,
                left: 16,
                bottom: 24,
                right: 16
            )
            infoContainerStackView.isLayoutMarginsRelativeArrangement = true

            let titleLabel = UILabel(value: cashback.name ?? "", style: .blockRowTitle)
            infoContainerStackView.addArrangedSubview(titleLabel)

            let descriptionLabel = MultilineLabel(
                styledText: StyledText(text: cashback.description ?? "", style: .blockRowDescription)
            )
            bag += infoContainerStackView.addArangedSubview(descriptionLabel)

            infoContainer.addSubview(infoContainerStackView)
            stackView.addArrangedSubview(infoContainer)

            infoContainerStackView.snp.makeConstraints({ make in
                make.width.height.centerX.centerY.equalToSuperview()
            })

            bag += infoContainerStackView.didLayoutSignal.onValue({ _ in
                let size = infoContainerStackView.systemLayoutSizeFitting(CGSize.zero)

                infoContainer.snp.remakeConstraints({ make in
                    make.height.equalTo(size.height)
                    make.width.equalToSuperview().inset(20)
                })
            })
            
            let button = Button(
                title: String(.PROFILE_MY_CHARITY_INFO_BUTTON),
                type: .iconTransparent(textColor: .purple, icon: Asset.infoPurple)
            )
            
            bag += button.onTapSignal.onValue {_ in
                self.presentingViewController.present(
                    DraggableOverlay(
                        presentable: CharityInformation(),
                        presentationOptions: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .prefersNavigationBarHidden(true)],
                        heightPercentage: 0.55
                    )
                )
            }
            
            bag += stackView.addArangedSubview(button)
        }

        if animateEntry {
            stackView.alpha = 0
            stackView.transform = CGAffineTransform(translationX: 0, y: 100)

            bag += events.wasAdded.delay(by: 1.2).animated(style: SpringAnimationStyle.lightBounce()) {
                stackView.alpha = 1
                stackView.transform = CGAffineTransform.identity
            }
        }

        stackView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        return (scrollView, bag)
    }
}
