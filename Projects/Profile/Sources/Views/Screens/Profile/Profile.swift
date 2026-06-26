import Apollo
import AppStateContainer
import Home
import SwiftUI
import hCore
import hCoreUI

public struct ProfileView: View {
    @AppObservedObject var store: ProfileStore
    @State private var showLogoutAlert = false

    private var logoutAlert: SwiftUI.Alert {
        Alert(
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
            hSection {
                ProfileRow(row: .myInfo)
                certificatesView
                if store.partnerData?.shouldShowEuroBonus ?? false {
                    let number = store.partnerData?.sas?.eurobonusNumber ?? ""
                    let hasEntereNumber = !number.isEmpty
                    ProfileRow(
                        row: .eurobonus(hasEnteredNumber: hasEntereNumber)
                    )
                }
                if Dependencies.featureFlags().isClaimHistoryEnabled {
                    ProfileRow(row: .claimHistory)
                }
                ProfileRow(row: .information)
                ProfileRow(row: .settings)
                    .hWithoutDivider
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
            .hWithoutHorizontalPadding([.row, .divider])
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
        .task {
            await store.fetchProfileState()
        }
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await store.fetchProfileState()
        }
        .navigationTitle(L10n.profileTitle)
    }

    @ViewBuilder
    private var certificatesView: some View {
        if store.showTravelCertificate, store.canCreateInsuranceEvidence {
            ProfileRow(row: .certificates)
        } else if store.showTravelCertificate {
            ProfileRow(row: .travelCertificate)
        } else if store.canCreateInsuranceEvidence {
            ProfileRow(row: .insuranceEvidence)
        }
    }
}
