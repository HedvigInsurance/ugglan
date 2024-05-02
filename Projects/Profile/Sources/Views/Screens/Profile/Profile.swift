import Apollo
import Home
import Market
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ProfileView: View {
    @PresentableStore var store: ProfileStore
    @State private var showLogoutAlert = false

    public init() {
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
                ApplicationState.preserveState(.notLoggedIn)
                store.send(.logout)
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
                    //                        if store.state.showTravelCertificate {
                    ProfileRow(row: .travelCertificate)
                    //                        }
                    //                    if store.state.partnerData?.shouldShowEuroBonus ?? false {
                    let number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
                    let hasEntereNumber = !number.isEmpty
                    ProfileRow(
                        row: .eurobonus(hasEnteredNumber: hasEntereNumber)
                    )
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
        .hFormMergeBottomViewWithContentIfNeeded
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    RenewalCardView(showCoInsured: false)
                    NotificationsCardView()
                    hButton.LargeButton(type: .ghost) {
                        showLogoutAlert = true
                    } content: {
                        hText(L10n.logoutButton)
                            .foregroundColor(hSignalColor.redElement)
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        logoutAlert
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onAppear {
            store.send(.fetchProfileState)
        }
        .onPullToRefresh {
            await store.sendAsync(.fetchProfileState)
        }
    }
}

public enum ProfileResult {
    case resetAppLanguage
    case openChat
    case logout
    case registerForPushNotifications

}

extension ProfileView {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ProfileResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: ProfileView()
        ) { action in
            //            if case .openProfile = action {
            //                HostingJourney(rootView: MyInfoView())
            //                    .configureTitle(L10n.profileMyInfoRowTitle)
            //            } else if case .openAppInformation = action {
            //                HostingJourney(rootView: AppInfoView())
            //                    .configureTitle(L10n.profileAppInfo)
            //            } else if case let .openAppSettings(animated) = action {
            //                HostingJourney(
            //                    ProfileStore.self,
            //                    rootView: SettingsScreen(),
            //                    options: animated ? [.defaults] : [.defaults, .unanimated]
            //                ) { action in
            //                    if case let .deleteAccount(details) = action {
            //                        DeleteAccountView.deleteAccountJourney(details: details)
            //                    } else if case .deleteAccountAlreadyRequested = action {
            //                        DeleteAccountView.deleteRequestAlreadyPlacedJourney
            //                    if case .openLangaugePicker = action {
            //                        PickLanguage { _ in
            //                            let store: ProfileStore = globalPresentableStoreContainer.get()
            //                            store.send(.languageChanged)
            //                            store.send(.setOpenAppSettings(to: true))
            //                        } onCancel: {
            //                            let store: ProfileStore = globalPresentableStoreContainer.get()
            //                            store.send(.closeLanguagePicker)
            //                        }
            //                        .journey
            //                        .onAction(ProfileStore.self) { action in
            //                            if case .closeLanguagePicker = action {
            //                                DismissJourney()
            //                            }
            //                        }
            //                    }
            //                }
            //                .configureTitle(L10n.Profile.AppSettingsSection.Row.headline)
            //            } else if case .openEuroBonus = action {
            //                EuroBonusView.journey
            //            } else if case .openTravelCertificate = action {
            //                //                TravelInsuranceJourney.travelCertificatePush()
            //                DismissJourney()
            if case .languageChanged = action {
                resultJourney(.resetAppLanguage)
            } else if case .openChat = action {
                resultJourney(.openChat)
            } else if case .logout = action {
                resultJourney(.logout)
            } else if case .registerForPushNotifications = action {
                resultJourney(.registerForPushNotifications)
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
