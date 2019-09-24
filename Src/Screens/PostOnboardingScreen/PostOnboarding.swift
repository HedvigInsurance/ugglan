//
//  PostOnboarding.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Foundation
import UIKit
import Presentation
import Flow
import Form
import Apollo

struct PostOnboarding {
    let client: ApolloClient
    typealias Content = ReusableViewable<ImageTextAction, Button>
    
    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
    
    enum TableAction {
        case payment, push, pushSkip
    }
    
    func makeTable(
        isSwitching: Bool,
        onAction: @escaping (_ tableAction: TableAction) -> Void
    ) -> (Table<EmptySection, Content>, Disposable) {
        let bag = DisposeBag()
        
        let paymentButton = Button(
            title: String(key: .ONBOARDING_CONNECT_DD_CTA),
            type: .standard(backgroundColor: .primaryTintColor, textColor: .white)
        )
        
        bag += paymentButton.onTapSignal.onValue { _ in
            onAction(.payment)
        }
        
        let payment = ImageTextAction(
            image: Asset.paymentSetupIllustration.image,
            title: String(key: .ONBOARDING_CONNECT_DD_HEADLINE),
            body: isSwitching ?
                String(key: .ONBOARDING_CONNECT_DD_BODY_SWITCHERS) :
                String(key: .ONBOARDING_CONNECT_DD_BODY),
            actions: [paymentButton],
            showLogo: false
        )
        
        let pushNotificationsDoButton = Button(
            title: String(key: .ONBOARDING_ACTIVATE_NOTIFICATIONS_CTA),
            type: .standard(backgroundColor: .primaryTintColor, textColor: .white)
        )
        
        let pushNotificationsSkipButton = Button(
            title: String(key: .ONBOARDING_ACTIVATE_NOTIFICATIONS_DISMISS),
            type: .transparent(textColor: .pink)
        )
        
        bag += pushNotificationsDoButton.onTapSignal.onValue { _ in
            onAction(.push)
        }
        
        bag += pushNotificationsSkipButton.onTapSignal.onValue { _ in
            onAction(.pushSkip)
        }
        
        let pushNotifications = ImageTextAction(
            image: Asset.activatePushNotificationsIllustration.image,
            title: String(key: .ONBOARDING_ACTIVATE_NOTIFICATIONS_HEADLINE),
            body: String(key: .ONBOARDING_ACTIVATE_NOTIFICATIONS_BODY),
            actions: [
                pushNotificationsDoButton,
                pushNotificationsSkipButton
            ],
            showLogo: false
        )
        
        let table = Table(rows: [
            ReusableViewable(viewable: payment),
            ReusableViewable(viewable: pushNotifications)
        ])
        
        return (table, bag)
    }
}

extension PostOnboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionKit = CollectionKit<EmptySection, Content>(layout: layout, holdIn: bag)
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.isScrollEnabled = false
        collectionKit.view.contentInsetAdjustmentBehavior = .never
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            collectionKit.view.bounds.size
        }
        
        bag += viewController.install(collectionKit)
        
        func presentLoggedIn() {
            if let modalViewController = viewController.presentingViewController {
                viewController.dismiss(animated: true, completion: nil)
                modalViewController.present(LoggedIn(didSign: true), options: [])
            } else {
                viewController.present(LoggedIn(didSign: true), options: [])
            }
        }
        
        bag += self.client.isSwitchingInsurance.onValue { isSwitching in
            let (table, disposable) = self.makeTable(isSwitching: isSwitching) { action in
                switch action {
                case .payment:
                    viewController.present(
                        DirectDebitSetup(setupType: .postOnboarding),
                        style: .modally(
                            presentationStyle: .formSheet,
                            transitionStyle: nil,
                            capturesStatusBarAppearance: true
                        )
                    ).onValue { _ in
                        collectionKit.scrollToNextItem()
                    }
                case .push:
                    UIApplication.shared.appDelegate.registerForPushNotifications().onValue { _ in
                        presentLoggedIn()
                    }
                case .pushSkip:
                    presentLoggedIn()
                }
            }
            collectionKit.table = table
            bag += disposable
        }
        
        
        return (viewController, bag)
    }
}
