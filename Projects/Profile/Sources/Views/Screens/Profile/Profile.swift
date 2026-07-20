import Apollo
import AppStateContainer
import Home
import SwiftUI
import hCore
import hCoreUI

public struct ProfileView: View {
    @AppObservedObject var store: ProfileStore

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
                ProfileRow(row: .claimHistory)
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
                    LogoutButton()
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

// Extracted to its own View so its hButton/alert closures don't capture the
// enclosing ProfileView's `self`. ProfileView holds ProfileStore via
// @AppObservedObject (which wraps @StateObject), so any closure capturing
// ProfileView's `self` transitively pinned ProfileStore across logout —
// even closures that only mutate a local @State.
private struct LogoutButton: View {
    @State private var showAlert = false

    var body: some View {
        hButton(
            .large,
            .ghost,
            content: .init(title: L10n.logoutButton),
            { showAlert = true }
        )
        .hUseButtonTextColor(.red)
        .foregroundColor(hSignalColor.Red.element)
        .alert(L10n.logoutAlertTitle, isPresented: $showAlert) {
            Button(L10n.logoutAlertActionCancel, role: .cancel) {}
            Button(L10n.logoutAlertActionConfirm, role: .destructive) {
                ApplicationState.preserveState(.notLoggedIn)
                ApplicationState.state = .notLoggedIn
            }
        }
    }
}
