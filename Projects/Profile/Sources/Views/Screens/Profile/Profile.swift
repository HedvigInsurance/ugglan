import Apollo
import Home
import Market
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct ProfileView: View {
    @PresentableStore var store: ProfileStore
    @State private var showLogoutAlert = false

    private var logoutAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.logoutAlertTitle),
            message: nil,
            primaryButton: .cancel(Text(L10n.logoutAlertActionCancel)),
            secondaryButton: .destructive(Text(L10n.logoutAlertActionConfirm)) {
                ApplicationState.preserveState(.notLoggedIn)
                ApplicationState.state = .notLoggedIn
            }
        )
    }

    public var body: some View {
        hUpdatedForm {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state
                }
            ) { stateData in
                hSection {
                    ProfileRow(row: .myInfo)
                    if store.state.showTravelCertificate {
                        ProfileRow(row: .travelCertificate)
                    }
                    if store.state.partnerData?.shouldShowEuroBonus ?? false {
                        let number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
                        let hasEntereNumber = !number.isEmpty
                        ProfileRow(
                            row: .eurobonus(hasEnteredNumber: hasEntereNumber)
                        )
                    }
                    ProfileRow(row: .appInfo)
                    ProfileRow(row: .settings)
                        .hWithoutDivider
                }
                .sectionContainerStyle(.transparent)
                .padding(.top, .padding16)
                .hWithoutHorizontalPadding
                .hWithoutDividerPadding
            }
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    RenewalCardView(showCoInsured: false)
                    NotificationsCardView()
                    hButton.LargeButton(type: .ghost) {
                        showLogoutAlert = true
                    } content: {
                        hText(L10n.logoutButton)
                            .foregroundColor(hSignalColor.Red.element)
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        logoutAlert
                    }
                    .padding(.bottom, .padding16)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onAppear {
            store.send(.fetchProfileState)
        }
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await store.sendAsync(.fetchProfileState)
        }
        .configureTitle(L10n.profileTitle)
    }
}
