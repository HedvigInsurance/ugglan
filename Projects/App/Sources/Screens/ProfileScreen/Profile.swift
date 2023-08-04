import Apollo
import Flow
import Form
import Home
import Market
import Payment
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ProfileView: View {
    @PresentableStore var store: ProfileStore
    @State private var showLogoutAlert = false
    private let disposeBag = DisposeBag()

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        if store.state.openSettingsDirectly {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                store.send(.openAppSettings(animated: false))
            }
            store.send(.setOpenAppSettings(to: false))
        }
    }

    private var logoutAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.logoutAlertTitle),
            message: nil,
            primaryButton: .cancel(Text(L10n.logoutAlertActionCancel)),
            secondaryButton: .destructive(Text(L10n.logoutAlertActionConfirm)) {
                ApplicationState.preserveState(.marketPicker)
                UIApplication.shared.appDelegate.logout()
            }
        )
    }

    public var body: some View {
        hForm {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state
                }
            ) { stateData in
                hSection {
                    ProfileRow(row: .myInfo)
                    if hAnalyticsExperiment.paymentScreen {
                        ProfileRow(row: .payment)
                    }
                    if store.state.partnerData?.shouldShowEuroBonus ?? false {
                        let number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
                        let hasEntereNumber = !number.isEmpty
                        ProfileRow(
                            row: .eurobonus(hasEnteredNumber: hasEntereNumber)
                        )
                    }

                    //                    if hAnalyticsExperiment.showCharity {
                    //                        ProfileRow(row: .myCharity)
                    //                    }

                    ProfileRow(row: .appInfo)
                    ProfileRow(row: .settings)
                        .hWithoutDivider
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
                .padding(.top, 16)
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                ConnectPaymentCardView()
                RenewalCardView()
                NotificationsCardView()
                hButton.LargeButtonGhost {
                    showLogoutAlert = true
                } content: {
                    hText(L10n.logoutButton)
                        .foregroundColor(hSignalColorNew.redElement)
                }
                .alert(isPresented: $showLogoutAlert) {
                    logoutAlert
                }
            }
            .padding(16)
        }
        .onAppear {
            store.send(.fetchProfileState)
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .profile))
        .introspectScrollView { scrollView in
            let refreshControl = UIRefreshControl()
            scrollView.refreshControl = refreshControl
            disposeBag.dispose()
            disposeBag += refreshControl.store(
                store,
                send: {
                    ProfileAction.fetchProfileState
                },
                endOn: .fetchProfileStateCompleted
            )
        }
    }
}

public enum ProfileResult {
    case openPayment
}

extension ProfileView {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ProfileResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: ProfileView()
        ) { action in
            if case .openProfile = action {
                HostingJourney(rootView: MyInfoView())
                    .configureTitle(L10n.profileMyInfoRowTitle)
            } else if case .openPayment = action {
                resultJourney(.openPayment)
            } else if case .openAppInformation = action {
                HostingJourney(rootView: AppInfoView())
            } else if case .openCharity = action {
                AppJourney.businessModelDetailJourney
            } else if case let .openAppSettings(animated) = action {
                HostingJourney(
                    UgglanStore.self,
                    rootView: SettingsScreen(),
                    options: animated ? [.defaults] : [.defaults, .unanimated]
                ) { action in
                    if case let .deleteAccount(details) = action {
                        AppJourney.deleteAccountJourney(details: details)
                    } else if case .deleteAccountAlreadyRequested = action {
                        AppJourney.deleteRequestAlreadyPlacedJourney
                    } else if case .openLangaugePicker = action {
                        PickLanguage {
                            UIApplication.shared.appDelegate.bag += UIApplication.shared.appDelegate.window.present(
                                AppJourney.main
                            )
                            let store: ProfileStore = globalPresentableStoreContainer.get()
                            store.send(.setOpenAppSettings(to: true))
                        } onCancel: {
                            let store: UgglanStore = globalPresentableStoreContainer.get()
                            store.send(.closeLanguagePicker)

                        }
                        .journey
                        .onAction(UgglanStore.self) { action in
                            if case .closeLanguagePicker = action {
                                DismissJourney()
                            }
                        }
                    }
                }
                .configureTitle(L10n.Profile.AppSettingsSection.Row.headline)
            } else if case .openEuroBonus = action {
                EuroBonusView.journey
            }
        }
        .configureTitle(L10n.profileTitle)
        .configureTabBarItem(
            title: L10n.ProfileTab.title,
            image: hCoreUIAssets.profileTab.image,
            selectedImage: hCoreUIAssets.profileTabActive.image
        )
    }
}
