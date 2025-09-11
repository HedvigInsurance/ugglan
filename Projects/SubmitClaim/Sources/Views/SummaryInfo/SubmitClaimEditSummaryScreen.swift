import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimEditSummaryScreen: View {
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @State var purchasePrice: String = ""

    public init() {}

    public var body: some View {
        hForm {
            hSection(
                header: hText(L10n.Claims.Incident.Screen.header, style: .body1)
                    .foregroundColor(hTextColor.Opaque.secondary)
            ) {
                displayDateOfIncidentField()
                displayPlaceOfIncidentField()
            }

            hSection(
                header: hText(L10n.Claims.Item.Screen.title, style: .body1)
                    .foregroundColor(hTextColor.Opaque.secondary)
            ) {
                displayPlaceOfIncidentField()
                displayModelInfoField()
                displayDateOfPurchaseField()
                displayTypeOfDamageField()
            }
        }

        .hFormAttachToBottom {
            hSection {
                hSaveButton {
                    claimsNavigationVm.router.dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder func displayDateOfIncidentField() -> some View {
        let dateOfOccurenceStep = claimsNavigationVm.occurrencePlusLocationModel?.dateOfOccurrenceModel
        hRow {
            hText(L10n.Claims.Item.Screen.Date.Of.Incident.button)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .withCustomAccessory {
            Spacer()
            HStack(spacing: 0) {
                hText(dateOfOccurenceStep?.dateOfOccurence ?? "")
                    .foregroundColor(hTextColor.Opaque.primary).colorScheme(.light)
                    .padding(.vertical, 11)
                    .padding([.trailing, .leading], 12)
            }
            .cornerRadius(.cornerRadiusL)
        }
    }

    @ViewBuilder func displayPlaceOfIncidentField() -> some View {
        let locationStep = claimsNavigationVm.occurrencePlusLocationModel?.locationModel
        hRow {
            HStack {
                hText(L10n.Claims.Location.Screen.title)
                    .foregroundColor(hTextColor.Opaque.primary)
                Spacer()

                hText(locationStep?.getSelectedOption()?.displayName ?? "")
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .onTap {
            claimsNavigationVm.isLocationPickerPresented = true
        }
    }

    @ViewBuilder func displayModelInfoField() -> some View {
        let singleItemStep = claimsNavigationVm.singleItemModel
        hRow {
            HStack {
                hText(L10n.Claims.Item.Screen.Model.button)
                    .foregroundColor(hTextColor.Opaque.primary)
                Spacer()

                if let getBrandOrModelName = singleItemStep?.getBrandOrModelName() {
                    hText(getBrandOrModelName)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
        .onTap {}
    }

    @ViewBuilder func displayDateOfPurchaseField() -> some View {
        hRow {
            hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .withCustomAccessory {
            let singleItemStep = claimsNavigationVm.singleItemModel
            Spacer()
            HStack(spacing: 0) {
                if let date = singleItemStep?.purchaseDate {
                    hText(date)
                        .foregroundColor(hTextColor.Opaque.primary).colorScheme(.light)
                        .padding(.vertical, 11)
                        .padding([.trailing, .leading], 12)
                }
            }
            .cornerRadius(.cornerRadiusL)
        }
    }

    @ViewBuilder func displayTypeOfDamageField() -> some View {
        hRow {
            HStack {
                hText(L10n.Claims.Item.Screen.Damage.button)
                    .foregroundColor(hTextColor.Opaque.primary)

                Spacer()
            }
        }
        .withCustomAccessory {
            let singleItemStep = claimsNavigationVm.singleItemModel
            if let text = singleItemStep?.getChoosenDamagesAsText() {
                hText(text).foregroundColor(hTextColor.Opaque.primary)
            } else {
                hText(L10n.Claim.Location.choose)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .onTap {
            claimsNavigationVm.isDamagePickerPresented = true
        }
    }
}
