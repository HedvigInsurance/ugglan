import Apollo
import Flow
import Form
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
    private func getLogoutIcon() -> UIImage {
        let icon = hCoreUIAssets.logout.image.withTintColor(.brand(.destructive))
        return icon
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
        hForm(gradientType: .profile) {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state
                }
            ) { stateData in
                hSection {
                    ProfileRow(row: .myInfo, subtitle: stateData.memberFullName)

                    if hAnalyticsExperiment.showCharity {
                        ProfileRow(row: .myCharity, subtitle: nil)
                    }
                    if store.state.partnerData?.shouldShowEuroBonus ?? false {
                        let number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
                        let hasEntereNumber = !number.isEmpty
                        ProfileRow(
                            row: .eurobonus(hasEnteredNumber: hasEntereNumber),
                            subtitle: hasEntereNumber ? number : L10n.SasIntegration.connectYourNumber
                        )
                    }
                    if hAnalyticsExperiment.paymentScreen {
                        ProfileRow(row: .payment, subtitle: "\(stateData.monthlyNet) \(L10n.paymentCurrencyOccurrence)")
                    }
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
                hSection {
                    ProfileRow(row: .appInfo)
                    ProfileRow(row: .settings)

                    hRow {
                        HStack(spacing: 16) {
                            Image(uiImage: hCoreUIAssets.logout.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(.brand(.destructive)))
                            VStack(alignment: .leading, spacing: 2) {
                                hText(L10n.logoutButton).foregroundColor(Color(.brand(.destructive)))
                            }

                        }
                        .padding(0)
                    }
                    .withCustomAccessory({
                        Spacer()
                    })
                    .verticalPadding(12)
                    .onTap {
                        showLogoutAlert = true
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        logoutAlert
                    }
                }
                .withHeader {
                    hText(
                        L10n.Profile.AppSettingsSection.title,
                        style: .title2
                    )
                    .padding(.leading, 16)
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
            }
        }
        .withChatButton {
            store.send(.openFreeTextChat)
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
    case openFreeTextChat
}

extension ProfileView {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ProfileResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: ProfileView(),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case .openProfile = action {
                Journey(
                    MyInfo(),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .autoPop]
                ) { _ in
                    DismissJourney()
                }
            } else if case .openPayment = action {
                resultJourney(.openPayment)
            } else if case .openAppInformation = action {
                Journey(
                    AppInfo(type: .appInformation),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openCharity = action {
                AppJourney.businessModelDetailJourney
            } else if case .openAppSettings = action {
                Journey(
                    AppInfo(type: .appSettings),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openFreeTextChat = action {
                resultJourney(.openFreeTextChat)
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
