import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ForeverView: View {
    @PresentableStore var store: ForeverStore

    public var body: some View {
        hForm(gradientType: .forever) {
            HeaderView().slideUpAppearAnimation()
            DiscountCodeSectionView().slideUpAppearAnimation()
            InvitationTable().slideUpAppearAnimation()
        }
        .hFormAttachToBottom {
            VStack {
                Divider().background(Color(UIColor.brand(.primaryBorderColor))).padding(0).edgesIgnoringSafeArea(.all)
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData?.discountCode
                    }
                ) { code in
                    if let code = code {
                        hButton.LargeButtonFilled {
                            store.send(.showShareSheetWithNotificationReminder(code: code))
                        } content: {
                            hText(L10n.ReferralsEmpty.shareCodeButton)
                        }
                        .padding(.horizontal).padding(.vertical, 6)
                    }
                }
            }
            .background(Color(DefaultStyling.tabBarBackgroundColor).edgesIgnoringSafeArea(.all))
        }
        .navigationBarItems(
            trailing:
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData?.potentialDiscountAmount
                    }
                ) { discountAmount in
                    if let discountAmount = discountAmount {
                        Button(action: {
                            store.send(.showInfoSheet(discount: discountAmount.formattedAmount))
                        }) {
                            Image(uiImage: hCoreUIAssets.infoLarge.image).foregroundColor(hLabelColor.primary)
                        }
                    }
                }
        )
    }
}

extension ForeverView {
    public static func journey() -> some JourneyPresentation {
        HostingJourney(
            ForeverStore.self,
            rootView: ForeverView(),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case .showTemporaryCampaignDetail = action {
                TemporaryCampaignDetail().journey
            } else if case .showChangeCodeDetail = action {
                Journey(
                    ChangeCode(service: ForeverServiceGraphQL()),
                    style: .modally()
                )
                .onDismiss {
                    let store: ForeverStore = globalPresentableStoreContainer.get()
                    store.send(.fetch)
                }
            } else if case let .showShareSheetWithNotificationReminder(code) = action {
                pushNotificationJourney(onDismissAction: {
                    let store: ForeverStore = globalPresentableStoreContainer.get()
                    store.send(.showShareSheetOnly(code: code))
                }) {
                    shareSheetJourney(code: code)
                }
            } else if case let .showShareSheetOnly(code) = action {
                shareSheetJourney(code: code)
            } else if case let .showInfoSheet(discount) = action {
                infoSheetJourney(potentialDiscount: discount)
            } else if case .showPushNotificationsReminder = action {
                pushNotificationJourney {
                    ContinueJourney()
                }
            }
        }
        .configureTitle(L10n.referralsScreenTitle)
        .configureForeverTabBarItem
        .configureTabBarBorder
    }

    static func infoSheetJourney(potentialDiscount: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: InfoAndTermsView(potentialDiscount: potentialDiscount),
            style: .modally()
        )
        .onAction(ForeverStore.self) { action in
            if case .closeInfoSheet = action {
                DismissJourney()
            }
        }
    }

    static func shareSheetJourney(code: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: ActivityViewController(activityItems: [
                URL(
                    string: L10n.referralsLink(
                        code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    )
                ) ?? ""
            ]),
            style: .activityView
        )
    }

    static func pushNotificationJourney<ResultJourney: JourneyPresentation>(
        onDismissAction: (() -> Void)? = nil,
        @JourneyBuilder resultJourney: @escaping () -> ResultJourney
    ) -> some JourneyPresentation {
        GroupJourney {
            if !UIApplication.shared.isRegisteredForRemoteNotifications {
                HostingJourney(
                    ForeverStore.self,
                    rootView: PushNotificationReminderView(),
                    style: .modal
                ) { action in
                    DismissJourney()
                }
                .onDismiss {
                    if let onDismissAction = onDismissAction {
                        onDismissAction()
                    }
                }
            } else {
                resultJourney()
            }
        }
    }
}

public struct Forever {
    let service: ForeverService

    public init(service: ForeverService) { self.service = service }
}

extension Forever: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.referralsScreenTitle
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.edgesForExtendedLayout = [.top, .left, .right]
        let bag = DisposeBag()

        let infoBarButton = UIBarButtonItem(
            image: hCoreUIAssets.infoLarge.image,
            style: .plain,
            target: nil,
            action: nil
        )

        bag += infoBarButton.onValue {
            viewController.present(
                InfoAndTerms(
                    potentialDiscountAmountSignal: self.service.dataSignal.map {
                        $0?.potentialDiscountAmount
                    }
                ),
                style: .detented(.large)
            )
        }

        viewController.navigationItem.rightBarButtonItem = infoBarButton

        let tableKit = TableKit<String, InvitationRow>(style: .brandInset, holdIn: bag)
        bag += tableKit.delegate.heightForCell.set { index -> CGFloat in tableKit.table[index].cellHeight }

        bag += NotificationCenter.default.signal(forName: .costDidUpdate).onValue { _ in service.refetch() }

        let refreshControl = UIRefreshControl()

        bag += refreshControl.onValue {
            refreshControl.endRefreshing()
            self.service.refetch()
        }

        tableKit.view.refreshControl = refreshControl

        bag += tableKit.view.addTableHeaderView(Header(service: service), animated: false)

        let containerView = UIView()
        viewController.view = containerView

        containerView.addSubview(tableKit.view)

        tableKit.view.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

        bag += service.dataSignal.atOnce().compactMap { $0?.invitations }
            .onValue { invitations in
                var table = Table(sections: [
                    (
                        L10n.ReferralsActive.Invited.title,
                        invitations.map { InvitationRow(invitation: $0) }
                    )
                ])
                table.removeEmptySections()
                tableKit.set(table)
            }

        let shareButton = ShareButton()

        bag +=
            containerView.add(shareButton) { buttonView in
                buttonView.snp.makeConstraints { make in make.bottom.leading.trailing.equalToSuperview()
                }

                bag += buttonView.didLayoutSignal.onValue {
                    let bottomInset = buttonView.frame.height - buttonView.safeAreaInsets.bottom
                    tableKit.view.scrollIndicatorInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: bottomInset,
                        right: 0
                    )
                    tableKit.view.contentInset = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: bottomInset,
                        right: 0
                    )
                }
            }
            .withLatestFrom(service.dataSignal.atOnce().compactMap { $0?.discountCode })
            .onValue { buttonView, discountCode in shareButton.loadableButton.startLoading()
                viewController.presentConditionally(
                    PushNotificationReminder(),
                    style: .detented(.large)
                )
                .onResult { _ in
                    let encodedDiscountCode =
                        discountCode.addingPercentEncoding(
                            withAllowedCharacters: .urlQueryAllowed
                        ) ?? ""
                    let activity = ActivityView(
                        activityItems: [
                            URL(string: L10n.referralsLink(encodedDiscountCode)) ?? ""
                        ],
                        applicationActivities: nil,
                        sourceView: buttonView,
                        sourceRect: buttonView.bounds
                    )
                    viewController.present(activity)
                    shareButton.loadableButton.stopLoading()
                }
            }

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .forever))

        return (viewController, bag)
    }
}
