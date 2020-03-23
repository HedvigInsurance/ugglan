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
        viewController.present(
            BankIdSign().withCloseButton,
            style: .modally(),
            options: [.defaults]
        ).onValue { _ in
            self.analyticsCoordinator.logEcommercePurchase()
            viewController.present(PostOnboarding(), style: .defaultOrModal, options: [])
        }
    }

    static var primaryAccentColor: UIColor {
        .primaryBackground
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
        chatButton.tintColor = .primaryText

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

        item.rightBarButtonItem = chatButton

        let titleViewContainer = UIStackView()
        titleViewContainer.isLayoutMarginsRelativeArrangement = true
        titleViewContainer.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 5)

        let titleView = UIStackView()
        titleView.axis = .vertical
        titleView.spacing = 0
        titleView.alignment = .center
        titleView.distribution = .fillProportionally

        titleView.addArrangedSubview(UILabel(value: String(key: .OFFER_TITLE), style: .body))

        let addressLabel = UILabel(value: " ", style: .navigationSubtitle)
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
            .atValue { insurance in
                addressLabel.text = insurance.address
            }
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
        let viewController = UIViewController()
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

        let offerHeader = OfferHeader(
            containerScrollView: scrollView,
            presentingViewController: viewController
        )
        bag += stackView.addArranged(offerHeader.wrappedIn(UIStackView())) { stackView in
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 25, verticalInset: 35)
            stackView.isLayoutMarginsRelativeArrangement = true
        }

        bag += stackView.addArranged(Spacing(height: 16))

        bag += stackView.addArranged(Spacing(height: Float(UIScreen.main.bounds.height))) { spacingView in
            bag += Signal(after: 1.25).animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                spacingView.animationSafeIsHidden = true
            }
        }

        bag += stackView.addArranged(OfferSummary())

        let insuredAtOtherCompanySignal = insuranceSignal
            .map { $0.previousInsurer != nil }
            .readable(initial: false)

        bag += stackView.addArranged(OfferCoverageTerms(insuredAtOtherCompanySignal: insuredAtOtherCompanySignal))

        let coverageSwitcher = WhenEnabled(insuredAtOtherCompanySignal, {
            OfferCoverageSwitcher()
        }) { _ in
        }

        bag += stackView.addArranged(coverageSwitcher)

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

        let offerSignButton = OfferSignButton()
        
        bag += offerSignButton.onTapSignal.onValue { _ in
            self.startSignProcess(viewController)
        }

        bag += view.add(offerSignButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.trailing.leading.equalToSuperview()
            }
            
            let spacerView = UIView()
            stackView.addArrangedSubview(spacerView)
            
            spacerView.snp.makeConstraints { make in
                make.height.equalTo(buttonView.snp.height)
            }
            
            bag += spacerView.didLayoutSignal.onValue { _ in
                scrollView.scrollIndicatorInsets = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: spacerView.frame.height - buttonView.safeAreaInsets.bottom,
                    right: 0
                )
            }

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

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.trailing.leading.bottom.equalToSuperview()
        }

        return (viewController, bag)
    }
}
