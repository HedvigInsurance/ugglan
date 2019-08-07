//
//  Offer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-31.
//

import Flow
import Form
import Presentation
import UIKit
import Apollo

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
            bag += viewController.present(chatOverlay).onValue { _ in }
        }
        
        item.leftBarButtonItem = chatButton
        
        let signButton = UIBarButtonItem(title: "Signera")
        item.rightBarButtonItem = signButton
        
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
        
        bag += stackView.addArranged(PriceBubble())
        bag += stackView.addArranged(OfferCoverageHeader())
        bag += stackView.addArranged(OfferCoverageHome(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageStuff(presentingViewController: viewController))
        bag += stackView.addArranged(OfferCoverageMe(presentingViewController: viewController))
        bag += stackView.addArranged(OfferReadyToSign(containerScrollView: scrollView))
        
        let view = UIView()
        view.backgroundColor = .darkPurple
        viewController.view = view
        
        let (navigationBarBag, navigationBar) = addNavigationBar(view, viewController)
        bag += navigationBarBag
        
        scrollView.backgroundColor = .darkPurple
        scrollView.embedView(stackView, scrollAxis: .vertical)
        
        view.addSubview(scrollView)
        
        let button = Button(title: "Skaffa Hedvig", type: .standard(backgroundColor: .white, textColor: .offBlack))
        
        bag += button.onTapSignal.onValue { _ in
            bag += self.client.subscribe(
                subscription: SignStatusSubscription()
            ).compactMap { $0.data?.signStatus?.status?.signState }
                .filter { state in state == .completed }
                .take(first: 1)
                .onValue { state in
                viewController.present(LoggedIn(), options: [.prefersNavigationBarHidden(true)])
            }
            
            bag += self.client.perform(mutation: SignOfferMutation()).onValue { result in result.data?.signOfferV2.autoStartToken }.onValue { autoStartToken in
                print(autoStartToken)
            }
        }
        
        bag += view.add(button) { buttonView in
            buttonView.layer.shadowOffset = CGSize(width: 5, height: 5)
            buttonView.layer.shadowRadius = 10
            buttonView.layer.shadowColor = UIColor.black.cgColor
            
            buttonView.snp.makeConstraints({ make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            })
            
            bag += scrollView.contentOffsetSignal.animated(style: SpringAnimationStyle.lightBounce()) { contentOffset in
                if contentOffset.y > 100 {
                    buttonView.transform = CGAffineTransform.identity
                } else {
                    buttonView.transform = CGAffineTransform(translationX: 0, y: buttonView.frame.height + view.safeAreaInsets.bottom + 20)
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
