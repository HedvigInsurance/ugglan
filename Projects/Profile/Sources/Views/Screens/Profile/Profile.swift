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
        hForm {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state
                }
            ) { stateData in
                hSection {
                    ProfileRow(row: .myInfo)
                    certificatesView(for: stateData)
                    if store.state.partnerData?.shouldShowEuroBonus ?? false {
                        let number = store.state.partnerData?.sas?.eurobonusNumber ?? ""
                        let hasEntereNumber = !number.isEmpty
                        ProfileRow(
                            row: .eurobonus(hasEnteredNumber: hasEntereNumber)
                        )
                    }
                    if store.state.hasClaims {
                        ProfileRow(row: .claimHistory)
                    }
                    ProfileRow(row: .appInfo)
                    ProfileRow(row: .settings)
                        .hWithoutDivider
                }
                .sectionContainerStyle(.transparent)
                .padding(.top, .padding16)
                .hWithoutHorizontalPadding([.row, .divider])
            }
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    RenewalCardView(showCoInsured: false)
                    NotificationsCardView()
                    hButton(
                        .large,
                        .ghost,
                        content: .init(
                            title: L10n.logoutButton
                        ),
                        {
                            showLogoutAlert = true
                        }
                    )
                    .hUseButtonTextColor(.red)
                    .foregroundColor(hSignalColor.Red.element)
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
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await store.sendAsync(.fetchProfileState)
        }
        .configureTitle(L10n.profileTitle)
    }

    @ViewBuilder
    private func certificatesView(for stateData: ProfileState) -> some View {
        if stateData.showTravelCertificate && stateData.canCreateInsuranceEvidence {
            ProfileRow(row: .certificates)
        } else if store.state.showTravelCertificate {
            ProfileRow(row: .travelCertificate)
        } else if stateData.canCreateInsuranceEvidence {
            ProfileRow(row: .insuranceEvidence)
        }
    }
}
