import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ForeverView: View {
    @PresentableStore var store: ForeverStore

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                HeaderView()
                DiscountCodeSectionView()
                InvitationTable()
            }
        }
        .onAppear {
            store.send(.fetch)
        }
        .hFormAttachToBottom {
            VStack {
                Divider().background(Color(UIColor.brandNew(.primaryBorderColor))).padding(0)
                    .edgesIgnoringSafeArea(.all)
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData?.discountCode
                    }
                ) { code in
                    if let code = code {
                        hButton.LargeButtonPrimary {
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
                            Image(uiImage: hCoreUIAssets.infoIcon.image)
                                .foregroundColor(hTextColorNew.primary)
                        }
                    }
                }
        )
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .forever))
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
            if case .showChangeCodeDetail = action {
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
            rootView: InfoView(
                title: L10n.ReferralsInfoSheet.headline,
                description: L10n.ReferralsInfoSheet.body(potentialDiscount),
                onDismiss: {
                    let store: ForeverStore = globalPresentableStoreContainer.get()
                    store.send(.closeInfoSheet)
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
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
struct ForeverView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore

    static var previews: some View {
        ForeverView()
            .onAppear {
                store.send(
                    .setForeverData(
                        data: .init(
                            grossAmount: .sek(200),
                            netAmount: .sek(180),
                            potentialDiscountAmount: .sek(50),
                            otherDiscounts: .sek(0),
                            discountCode: "CODE",
                            invitations: [
                                .init(name: "First", state: .active, discount: .sek(20), invitedByOther: true),
                                .init(name: "Second", state: .active, invitedByOther: false),
                                .init(name: "Third", state: .terminated, invitedByOther: false),
                            ]
                        )
                    )
                )
            }
    }
}
