import Apollo
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ProfileView: View {
    @PresentableStore var store: ProfileStore
    @State private var showLogoutAlert = false

    private func getLogoutIcon() -> UIImage {
        let icon = Asset.logoutIcon.image.withTintColor(.brand(.destructive))
        return icon
    }

    private var logoutAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.logoutAlertTitle),
            message: nil,
            primaryButton: .cancel(Text(L10n.logoutAlertActionCancel)),
            secondaryButton: .destructive(Text(L10n.logoutAlertActionConfirm)) {
                ApplicationState.preserveState(.marketPicker)
                UIApplication.shared.appDelegate.logout(token: nil)
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
                    ProfileRow(
                        title: L10n.profileMyInfoRowTitle,
                        subtitle: stateData.memberFullName,
                        icon: Asset.myInfoRowIcon.image
                    ) {
                        store.send(.openProfile)
                    }
                    if hAnalyticsExperiment.showCharity {
                        ProfileRow(
                            title: L10n.profileMyCharityRowTitle,
                            subtitle: stateData.memberCharityName,
                            icon: Asset.charityPlain.image
                        ) {
                            store.send(.openCharity)
                        }
                    }
                    if hAnalyticsExperiment.paymentScreen {
                        ProfileRow(
                            title: L10n.profilePaymentRowHeader,
                            subtitle: "\(stateData.monthlyNet) \(L10n.paymentCurrencyOccurrence)",
                            icon: Asset.paymentRowIcon.image
                        ) {
                            store.send(.openPayment)
                        }
                    }
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
                hSection {
                    ProfileRow(
                        title: L10n.OnboardingContextualMenu.appInfoLabel,
                        subtitle: nil,
                        icon: Asset.infoIcon.image
                    ) {
                        store.send(.openAppInformation)
                    }
                    ProfileRow(
                        title: L10n.EmbarkOnboardingMoreOptions.settingsLabel,
                        subtitle: nil,
                        icon: Asset.settingsIcon.image
                    ) {
                        store.send(.openAppSettings)
                    }
                    hRow {
                        HStack(spacing: 16) {
                            Image(uiImage: Asset.logoutIcon.image)
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
        .onAppear {
            store.send(.fetchProfileState)
        }.trackOnAppear(hAnalyticsEvent.screenView(screen: .profile))
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
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openCharity = action {
                Journey(
                    Charity(),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openPayment = action {
                resultJourney(.openPayment)
            } else if case .openAppInformation = action {
                Journey(
                    AppInfo(type: .appInformation),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openAppSettings = action {
                Journey(
                    AppInfo(type: .appSettings),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            }
        }
        .configureTitle(L10n.profileTitle)
        .addConfiguration({ presenter in
            // - TODO - refactor
            let tabBarItem = UITabBarItem(
                title: L10n.profileTitle,
                image: Asset.profileTab.image,
                selectedImage: Asset.profileTabActive.image
            )
            presenter.viewController.tabBarItem = tabBarItem
        })
    }
}
