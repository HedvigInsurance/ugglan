import Apollo
import Flow
import Form
import Home
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

                    if hAnalyticsExperiment.showCharity {
                        ProfileRow(row: .myCharity)
                    }

                    if store.state.partnerData?.shouldShowEuroBonus ?? false {
                        let number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
                        let hasEntereNumber = !number.isEmpty
                        ProfileRow(
                            row: .eurobonus(hasEnteredNumber: hasEntereNumber)
                        )
                    }

                    if hAnalyticsExperiment.paymentScreen {
                        ProfileRow(row: .payment)
                    }

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
                Journey(
                    AppInfo(),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openCharity = action {
                AppJourney.businessModelDetailJourney
            } else if case .openAppSettings = action {
                HostingJourney(
                    UgglanStore.self,
                    rootView: SettingsScreen(),
                    options: [.defaults]
                ) { action in
                    if case let .deleteAccount(details) = action {
                        AppJourney.deleteAccountJourney(details: details)
                    } else if case .deleteAccountAlreadyRequested = action {
                        AppJourney.deleteRequestAlreadyPlacedJourney
                    }
                }
                .configureTitle(L10n.Profile.AppSettingsSection.Row.headline)
            } else if case .openEuroBonus = action {
                HostingJourney(
                    rootView: EuroBonusView(),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
                .configureTitle(L10n.SasIntegration.title)
            }
        }
        .configureTitle(L10n.profileTitle)
        .configureTabBarItem(
            title: L10n.profileTitle,
            image: hCoreUIAssets.profileTab.image,
            selectedImage: hCoreUIAssets.profileTabActive.image
        )
    }
}
