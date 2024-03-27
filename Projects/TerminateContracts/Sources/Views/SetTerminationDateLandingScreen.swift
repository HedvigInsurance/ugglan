import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDateLandingScreen: View {
    @PresentableStore var store: TerminationContractStore
    let onSelected: () -> Void
    @State var hasAgreedToTerms: Bool = false

    var body: some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state
            }
        ) { termination in
            hForm {
            }
            .hFormTitle(
                title: .init(.standard, .title3, L10n.terminationFlowCancellationTitle, alignment: .leading),
                subTitle: .init(
                    .standard,
                    .title3,
                    (termination.config?.isDeletion ?? false)
                        ? L10n.terminationFlowConfirmInformation : L10n.terminationDateText
                )
            )
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
                            displayInsuranceField(config: config)
                        }
                        displayTerminationDateField(termination: termination)
                        if let terminationDate = termination.terminationDateStep?.date {
                            displayImportantInformation(terminationDate: terminationDate)
                        }
                    }

                    hSection {
                        VStack(spacing: 16) {
                            hButton.LargeButton(type: .primary) {
                                onSelected()
                            } content: {
                                hText(L10n.terminationButton, style: .standard)
                            }
                            .disabled(disableCancelButton(termination: termination))
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
                .padding(.top, 16)
            }
        }
    }

    @ViewBuilder
    private func displayInsuranceField(config: TerminationConfirmConfig) -> some View {
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

    @ViewBuilder
    private func displayTerminationDateField(termination: TerminationContractState) -> some View {
        if termination.config?.isDeletion ?? false {
            hSection {
                VStack(spacing: 4) {
                    hFloatingField(
                        value: L10n.terminationFlowToday,
                        placeholder: L10n.terminationFlowDateFieldText,
                        onTap: {
                        }
                    )
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.lockSmall.image)
                            .frame(width: 24, height: 24)
                    }
                    .hFieldLockedState

                    InfoCard(
                        text:
                            L10n.terminationFlowDeletionInfoCard,
                        type: .info
                    )
                }
            }
            .sectionContainerStyle(.transparent)
        } else {
            VStack(spacing: 4) {
                hSection {
                    hFloatingField(
                        value: termination.terminationDateStep?.date?.displayDateDDMMMYYYYFormat
                            ?? L10n.terminationFlowDateFieldPlaceholder,
                        placeholder: L10n.terminationFlowDateFieldText,
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
        }
    }

    @ViewBuilder
    private func displayImportantInformation(terminationDate: Date) -> some View {
        hSection {
            hRow {
                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            hText(L10n.terminationFlowImportantInformationTitle)
                            hText(
                                L10n.terminationFlowImportantInformationText,
                                style: .standardSmall
                            )
                            .foregroundColor(hTextColor.secondary)
                        }
                    }

                    HStack {
                        hRow {
                            hText(L10n.terminationFlowIUnderstandText)
                            Spacer()
                            if hasAgreedToTerms {
                                HStack {
                                    Image(uiImage: hCoreUIAssets.tick.image)
                                        .foregroundColor(hTextColor.negative)
                                }
                                .frame(width: 24, height: 24)
                                .background(
                                    Squircle.default()
                                        .fill(hSignalColor.greenElement)
                                )
                            } else {
                                Circle()
                                    .fill(hBackgroundColor.clear)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                                            .strokeBorder(hBorderColor.translucentTwo, lineWidth: 2)
                                            .animation(.easeInOut)
                                    )

                            }
                        }
                        .background(
                            Squircle.default()
                                .fill(Color.white)
                        )
                    }
                }
            }
            .onTapGesture {
                if !hasAgreedToTerms {
                    hasAgreedToTerms = true
                } else {
                    hasAgreedToTerms = false
                }
            }
        }
    }

    private func disableCancelButton(termination: TerminationContractState) -> Bool {
        let isDeletion = termination.config?.isDeletion ?? false
        let hasSetTerminationDate = termination.terminationDateStep?.date != nil

        return !isDeletion && (!hasSetTerminationDate || !hasAgreedToTerms)
    }

    @hColorBuilder
    func getFillColor() -> some hColor {
        if hasAgreedToTerms {
            hSignalColor.greenElement
        } else {
            hFillColor.opaqueOne
        }
    }
}

#Preview{
    SetTerminationDateLandingScreen(onSelected: {})
}
