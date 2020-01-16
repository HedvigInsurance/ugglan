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
    @Inject var client: ApolloClient
    @Inject var analyticsCoordinator: AnalyticsCoordinator
}

extension Offer {
    func startSignProcess(_ viewController: UIViewController) {
        let overlay = DraggableOverlay(
            presentable: BankIdSign(),
            presentationOptions: [.prefersNavigationBarHidden(true)]
        )
        viewController.present(overlay).onValue { _ in
            self.analyticsCoordinator.logEcommercePurchase()
            viewController.present(PostOnboarding(), style: .defaultOrModal, options: [])
        }
    }
    
    static var primaryAccentColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .primaryBackground : .midnight500
        })
    }
}

extension Offer {
    func addNavigationBar(
        _ view: UIView,
        scrollView: UIScrollView,
        viewController: UIViewController
    ) -> (Disposable, UINavigationBar) {
        let bag = DisposeBag()

        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = Offer.primaryAccentColor
        navigationBar.isTranslucent = false
        navigationBar.alpha = 0
        navigationBar.transform = CGAffineTransform(translationX: 0, y: 5)

        let item = UINavigationItem()

        let chatButton = UIBarButtonItem()
        chatButton.image = Asset.chat.image
        chatButton.tintColor = .white

        bag += chatButton.onValue { _ in
            bag += viewController.present(
                OfferChat().withCloseButton,
                style: .modally(
                    presentationStyle: .pageSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                )
            ).disposable
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
            self.startSignProcess(viewController)
        }

        let signButtonBarItem = UIBarButtonItem(viewable: signButton)
        item.rightBarButtonItem = signButtonBarItem

        bag += scrollView.contentOffsetSignal.animated(style: SpringAnimationStyle.lightBounce()) { contentOffset in
            if contentOffset.y > 400 {
                signButtonBarItem.view?.alpha = 0
                signButtonBarItem.view?.transform = CGAffineTransform(translationX: 0, y: 5)
            } else {
                signButtonBarItem.view?.alpha = 1
                signButtonBarItem.view?.transform = CGAffineTransform.identity
            }
        }

        let titleViewContainer = UIStackView()
        titleViewContainer.isLayoutMarginsRelativeArrangement = true
        titleViewContainer.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 5)

        let titleView = UIStackView()
        titleView.axis = .vertical
        titleView.spacing = 0
        titleView.alignment = .center
        titleView.distribution = .fillProportionally

        titleView.addArrangedSubview(UILabel(value: String(key: .OFFER_TITLE), style: .bodyWhite))

        let addressLabel = UILabel(value: " ", style: .navigationSubtitleWhite)
        titleView.addArrangedSubview(addressLabel)

        titleViewContainer.addArrangedSubview(titleView)

        bag += titleViewContainer.didMoveToWindowSignal.take(first: 1).onValue { _ in
            titleViewContainer.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
        }

        bag += client
            .fetch(query: OfferQuery())
            .valueSignal
            .compactMap { $0.data?.insurance }
            .atValue({ insurance in
                addressLabel.text = insurance.address
            })
            .animated(style: AnimationStyle.easeOut(duration: 0.25, delay: 0.65)) { _ in
                navigationBar.alpha = 1
                navigationBar.transform = CGAffineTransform.identity
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
        analyticsCoordinator.logAddToCart()

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
        
        let startDateButton = OfferStartDateButton(containerScrollView: scrollView, presentingViewController: viewController)
        bag += stackView.addArranged(startDateButton)
        
        bag += stackView.addArranged(Spacing(height: 16))

        let offerDiscount = OfferDiscount(containerScrollView: scrollView, presentingViewController: viewController)
        bag += offerSignal.compactMap { $0.data?.redeemedCampaigns }.bindTo(offerDiscount.redeemedCampaignsSignal)

        bag += stackView.addArranged(offerDiscount)

        bag += stackView.addArranged(Spacing(height: Float(UIScreen.main.bounds.height))) { spacingView in
            bag += Signal(after: 1.25).animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                spacingView.animationSafeIsHidden = true
            }
        }

        bag += stackView.addArranged(OfferSummary())
        bag += stackView.addArranged(OfferCoverageHome(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageStuff(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageMe(presentingViewController: viewController))

        let insuredAtOtherCompanySignal = insuranceSignal
            .map { $0.previousInsurer != nil }
            .readable(initial: false)

        bag += stackView.addArranged(OfferCoverageTerms(insuredAtOtherCompanySignal: insuredAtOtherCompanySignal))

        bag += stackView.addArranged(WhenEnabled(insuredAtOtherCompanySignal, {
            OfferCoverageSwitcher()
        }))

        bag += stackView.addArranged(OfferReadyToSign(containerScrollView: scrollView))

        let view = UIView()
        view.backgroundColor = Offer.primaryAccentColor
        viewController.view = view

        let (navigationBarBag, navigationBar) = addNavigationBar(
            view,
            scrollView: scrollView,
            viewController: viewController
        )
        bag += navigationBarBag

        scrollView.backgroundColor = Offer.primaryAccentColor
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
            self.startSignProcess(viewController)
        }

        bag += view.add(button) { buttonView in
            bag += buttonView.applyShadow({ _ in
                UIView.ShadowProperties(
                    opacity: 0.1,
                    offset: CGSize(width: 0, height: 2),
                    radius: 5,
                    color: UIColor.primaryShadowColor,
                    path: nil
                )
            })

            buttonView.snp.makeConstraints({ make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).priority(.high)
                make.bottom.lessThanOrEqualTo(-20).priority(.required)
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
