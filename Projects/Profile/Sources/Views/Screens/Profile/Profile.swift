import Apollo
import AppStateContainer
import Environment
import Home
import SwiftUI
import hCore
import hCoreUI

public struct ProfileView: View {
    @AppObservedObject var store: ProfileStore
    @AppObservedObject private var featureFlags: FeatureFlagsStore
    @SwiftUI.Environment(\.actingPowerOfAttorney) private var actingPowerOfAttorney

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
                // Someone acting with a power of attorney mustn't grant new ones on the member's behalf
                if featureFlags.isPowerOfAttorneyEnabled, actingPowerOfAttorney == nil {
                    ProfileRow(row: .powerOfAttorney)
                }
                ProfileRow(row: .information)
                if Environment.current != .production {
                    ProfileRow(row: .settings)
                    ProfileRow(row: .devSettings)
                        .hWithoutDivider
                } else {
                    ProfileRow(row: .settings)
                        .hWithoutDivider
                }
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
