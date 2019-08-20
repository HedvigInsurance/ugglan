//
//  Offer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-31.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct Offer {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension Offer {
    func addNavigationBar(
        _ view: UIView,
        _ viewController: UIViewController
    ) -> (Disposable, UINavigationBar) {
        let bag = DisposeBag()

        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .darkPurple
        navigationBar.isTranslucent = false

        let item = UINavigationItem()

        let chatButton = UIBarButtonItem()
        chatButton.image = Asset.chat.image
        chatButton.tintColor = .white

        bag += chatButton.onValue { _ in
            let chatOverlay = DraggableOverlay(presentable: OfferChat(), adjustsToKeyboard: false)
            bag += viewController.present(chatOverlay).disposable
        }

        item.leftBarButtonItem = chatButton

        let signButton = Button(
            title: String(key: .OFFER_BANKID_SIGN_BUTTON),
            type: .tinyIcon(
                backgroundColor: .white,
                textColor: .black,
                icon: .right(image: Asset.bankIdLogo.image, width: 13)
            )
        )

        bag += signButton.onTapSignal.onValue { _ in
            let overlay = DraggableOverlay(presentable: BankIdSign(), presentationOptions: [.prefersNavigationBarHidden(true)])
            viewController.present(overlay)
        }

        let signButtonBarItem = UIBarButtonItem(viewable: signButton)
        item.rightBarButtonItem = signButtonBarItem

        let titleViewContainer = UIStackView()
        titleViewContainer.isLayoutMarginsRelativeArrangement = true
        titleViewContainer.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 5)

        let titleView = UIStackView()
        titleView.axis = .vertical
        titleView.spacing = 0
        titleView.alignment = .center
        titleView.distribution = .fillProportionally

        titleView.addArrangedSubview(UILabel(value: String(key: .OFFER_TITLE), style: .bodyWhite))

        let addressLabel = UILabel(value: "", style: .navigationSubtitleWhite)
        titleView.addArrangedSubview(addressLabel)

        titleViewContainer.addArrangedSubview(titleView)

        bag += titleViewContainer.didMoveToWindowSignal.take(first: 1).onValue { _ in
            titleViewContainer.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
        }

        bag += client.fetch(query: OfferQuery()).valueSignal.compactMap { $0.data?.insurance }.onValue { insurance in
            addressLabel.text = insurance.address
        }

        item.titleView = titleViewContainer

        navigationBar.items = [item]

        view.addSubview(navigationBar)

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailingMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leadingMargin)
        }

        return (bag, navigationBar)
    }
}

extension Offer: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = LightContentViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 80)

        ApplicationState.preserveState(.offer)

        let bag = DisposeBag()

        let stackView = UIStackView()
        stackView.axis = .vertical

        let scrollView = UIScrollView()

        let offerSignal = client.watch(query: OfferQuery())

        let insuranceSignal = offerSignal
            .compactMap { $0.data?.insurance }

        let priceBubble = PriceBubble(containerScrollView: scrollView)
        bag += stackView.addArranged(priceBubble)

        bag += offerSignal
            .compactMap { $0.data }
            .bindTo(priceBubble.dataSignal)

        let offerBubbles = OfferBubbles(containerScrollView: scrollView)
        bag += stackView.addArranged(offerBubbles)

        bag += insuranceSignal
            .bindTo(offerBubbles.insuranceSignal)

        let offerDiscount = OfferDiscount(containerScrollView: scrollView, presentingViewController: viewController)
        bag += offerSignal.compactMap { $0.data?.redeemedCampaigns }.bindTo(offerDiscount.redeemedCampaignsSignal)

        bag += stackView.addArranged(offerDiscount)

        bag += stackView.addArranged(Spacing(height: Float(UIScreen.main.bounds.height))) { spacingView in
            bag += Signal(after: 1).animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                spacingView.animationSafeIsHidden = true
            }
        }

        bag += stackView.addArranged(OfferCoverageHeader())
        bag += stackView.addArranged(OfferCoverageHome(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageStuff(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageMe(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageTerms())
        bag += stackView.addArranged(OfferReadyToSign(containerScrollView: scrollView))

        let view = UIView()
        view.backgroundColor = .darkPurple
        viewController.view = view

        let (navigationBarBag, navigationBar) = addNavigationBar(view, viewController)
        bag += navigationBarBag

        scrollView.backgroundColor = .darkPurple
        scrollView.embedView(stackView, scrollAxis: .vertical)

        view.addSubview(scrollView)

        let button = Button(
            title: String(key: .OFFER_SIGN_BUTTON),
            type: .standardIcon(
                backgroundColor: .white,
                textColor: .offBlack,
                icon: .right(image: Asset.bankIdLogo.image, width: 20)
            )
        )

        bag += button.onTapSignal.onValue { _ in
            viewController.present(DraggableOverlay(presentable: BankIdSign()))
        }

        bag += view.add(button) { buttonView in
            buttonView.layer.shadowOffset = CGSize(width: 0, height: 2)
            buttonView.layer.shadowRadius = 5
            buttonView.layer.shadowColor = UIColor.black.cgColor
            buttonView.layer.shadowOpacity = 0.1

            buttonView.snp.makeConstraints({ make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            })

            buttonView.transform = CGAffineTransform(
                translationX: 0,
                y: 200
            )

            bag += scrollView.contentOffsetSignal.animated(style: SpringAnimationStyle.lightBounce()) { contentOffset in
                if contentOffset.y > 400 {
                    buttonView.transform = CGAffineTransform.identity
                } else {
                    buttonView.transform = CGAffineTransform(
                        translationX: 0,
                        y: buttonView.frame.height + view.safeAreaInsets.bottom + 20
                    )
                }
            }
        }

        scrollView.snp.makeConstraints({ make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.trailing.leading.bottom.equalToSuperview()
        })

        return (viewController, bag)
    }
}
