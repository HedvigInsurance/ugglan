import Apollo
import Flow
import Form
import Foundation
import Payment
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

struct PostOnboarding {
    @Inject var client: ApolloClient
    typealias Content = ReusableSignalViewable<ImageTextAction<TableAction>, TableAction>

    enum TableAction { case payment, push, pushSkip }

    func makeTable(
        isSwitching: Bool,
        onAction: @escaping (_ tableAction: TableAction) -> Void
    ) -> (Table<EmptySection, Content>, Disposable) {
        let bag = DisposeBag()

        let paymentButton = Button(
            title: L10n.PayInExplainer.buttonText,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        bag += paymentButton.onTapSignal.onValue { _ in onAction(.payment) }

        let payment = ImageTextAction<TableAction>(
            image: .init(
                image: Asset.paymentSetupIllustration.image,
                size: CGSize(width: CGFloat.infinity, height: 200),
                contentMode: .scaleAspectFit
            ),
            title: L10n.PayInExplainer.headline,
            body: isSwitching ? L10n.onboardingConnectDdBodySwitchers : L10n.PayInExplainer.body,
            actions: [(.payment, paymentButton)],
            showLogo: false
        )

        let pushNotificationsDoButton = Button(
            title: L10n.onboardingActivateNotificationsCta,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        let pushNotificationsSkipButton = Button(
            title: L10n.onboardingActivateNotificationsDismiss,
            type: .transparent(textColor: .brand(.primaryText()))
        )

        bag += pushNotificationsDoButton.onTapSignal.onValue { _ in onAction(.push) }

        bag += pushNotificationsSkipButton.onTapSignal.onValue { _ in onAction(.pushSkip) }

        let pushNotifications = ImageTextAction<TableAction>(
            image: .init(
                image: Asset.activatePushNotificationsIllustration.image,
                size: CGSize(width: CGFloat.infinity, height: 200),
                contentMode: .scaleAspectFit
            ),
            title: L10n.onboardingActivateNotificationsHeadline,
            body: L10n.onboardingActivateNotificationsBody,
            actions: [(.push, pushNotificationsDoButton), (.pushSkip, pushNotificationsSkipButton)],
            showLogo: false
        )

        let table = Table(
            rows: [
                hAnalyticsExperiment.postOnboardingShowPaymentStep ? ReusableSignalViewable(viewable: payment) : nil,
                ReusableSignalViewable(viewable: pushNotifications),
            ]
            .compactMap { $0 }
        )

        return (table, bag)
    }
}

extension PostOnboarding: Presentable {
    func materialize() -> (UIViewController, Signal<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.navigationItem.hidesBackButton = true
        viewController.isModalInPresentation = true

        ApplicationState.preserveState(.loggedIn)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionKit = CollectionKit<EmptySection, Content>(layout: layout, holdIn: bag)
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.isScrollEnabled = false
        collectionKit.view.contentInsetAdjustmentBehavior = .never
        collectionKit.view.backgroundColor = .brand(.secondaryBackground())

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in collectionKit.view.bounds.size }

        bag += viewController.install(collectionKit)

        return (
            viewController,
            Signal { callback in
                bag += client.isSwitchingInsurance.onValue { isSwitching in
                    let (table, disposable) = self.makeTable(isSwitching: isSwitching) { action in
                        switch action {
                        case .payment:
                            viewController.present(
                                PaymentSetup(
                                    setupType: .postOnboarding,
                                    urlScheme: Bundle.main.urlScheme ?? ""
                                )
                                .journeyThenDismiss
                                .onDismiss {
                                    collectionKit.scrollToNextItem()
                                }
                            )
                            .sink()
                        case .push:
                            UIApplication.shared.appDelegate.registerForPushNotifications()
                                .onValue { _ in callback(()) }
                        case .pushSkip: callback(())
                        }
                    }
                    collectionKit.table = table
                    bag += disposable
                }

                return bag
            }
        )
    }
}
