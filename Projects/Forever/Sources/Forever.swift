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
    @State var disposeBag = DisposeBag()

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
            PresentableStoreLens(
                ForeverStore.self,
                getter: { state in
                    state.foreverData?.discountCode
                }
            ) { code in
                if let code = code {
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButtonPrimary {
                                store.send(.showShareSheetWithNotificationReminder(code: code))
                            } content: {
                                hText(L10n.ReferralsEmpty.shareCodeButton)
                            }

                            hButton.LargeButtonGhost {
                                store.send(.showChangeCodeDetail)
                            } content: {
                                hText(L10n.ReferralsChange.changeCode)
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                    .padding(.vertical, 16)

                }
            }
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
                            Image(uiImage: hCoreUIAssets.infoIcon.image).foregroundColor(hLabelColor.primary)
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
            rootView: ForeverView()
        ) { action in
            if case .showChangeCodeDetail = action {
                getChangeCodeJourney()
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

struct ForeverView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return ForeverView()
            .onAppear {
                let foreverData = ForeverData.mock()
                store.send(.setForeverData(data: foreverData))
            }
    }
}

extension ForeverView {
    static func getChangeCodeJourney() -> some JourneyPresentation {
        let store: ForeverStore = globalPresentableStoreContainer.get()
        let vm = TextInputViewModel(
            input: store.state.foreverData?.discountCode ?? "",
            title: "Change your code"
        ) { text in
            FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += ForeverServiceGraphQL().changeDiscountCode(text)
                    .onValue { value in
                        if let error = value.right {
                            callback(.value(error.localizedDescription))
                        } else {
                            callback(.value(nil))
                            store.send(.dismissChangeCodeDetail)
                            store.send(.fetch)
                        }
                    }
                return disposeBag
            }
        } dismiss: {
            store.send(.dismissChangeCodeDetail)
        }

        let view = TextInputView(vm: vm)
        return HostingJourney(
            ForeverStore.self,
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: .largeNavigationBar
        ) { action in
            if case .dismissChangeCodeDetail = action {
                DismissJourney()
            }
        }
        .onDismiss {
            let store: ForeverStore = globalPresentableStoreContainer.get()
            store.send(.fetch)
        }
        .configureTitle(L10n.ReferralsChange.changeCode)
    }
}
