import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDateLandingScreen: View {
    @PresentableStore var store: TerminationContractStore
    let onSelected: () -> Void
    let includeMarker: () -> String?

    var body: some View {
        hForm {
            hSection {
                VStack {
                    Group {
                        HStack(spacing: 8) {
                            hText(L10n.terminationFlowCancellationTitle, style: .title3)
                            if let includeMarker = includeMarker() {
                                HStack {
                                    hText(includeMarker)
                                        .foregroundColor(hTextColor.secondary)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Squircle.default()
                                        .fill(hFillColor.opaqueOne)
                                )
                            }
                        }

                        hText(L10n.terminationDateText, style: .title3)
                            .foregroundColor(hTextColor.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            PresentableStoreLens(
                TerminationContractStore.self,
                getter: { state in
                    state
                }
            ) { termination in
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        if let config = termination.config {
                            hSection {
                                hRow {
                                    VStack(alignment: .leading) {
                                        hText(config.contractDisplayName)
                                        hText(config.contractExposureName, style: .standardSmall)
                                            .foregroundColor(hTextColor.secondaryTranslucent)
                                    }
                                }
                            }
                        }
                        hSection {
                            hFloatingField(
                                value: termination.terminationDateStep?.date?.displayDateDDMMMYYYYFormat
                                    ?? "Select date...",
                                placeholder: "Termination date",
                                onTap: {
                                    store.send(.navigationAction(action: .openTerminationDatePickerScreen))
                                },
                                lockedState: (termination.terminationDateStep?.date != nil) ? false : true
                            )
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.chevronDownSmall.image)
                            }
                        }
                    }

                    hSection {
                        VStack(spacing: 16) {
                            hButton.LargeButton(type: .primary) {
                                onSelected()
                            } content: {
                                hText(L10n.generalContinueButton, style: .standard)
                            }
                            .disabled(termination.terminationDateStep?.date == nil)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
                .padding(.top, 16)
            }
        }
    }
}

#Preview{
    SetTerminationDateLandingScreen(onSelected: {}, includeMarker: { return "2/2" })
}
