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
                state.isDeletion
            }
        ) { isDeletion in
            hForm {}
                .hFormTitle(
                    title: .init(.standard, .title3, L10n.terminationFlowCancellationTitle, alignment: .leading),
                    subTitle: .init(
                        .standard,
                        .title3,
                        isDeletion ? L10n.terminationFlowConfirmInformation : L10n.terminationDateText
                    )
                )
                .hFormAttachToBottom {
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            displayInsuranceField
                            displayTerminationDateField(isDeletion: isDeletion)
                            displayImportantInformation
                        }

                        hSection {
                            PresentableStoreLens(
                                TerminationContractStore.self,
                                getter: { state in
                                    state
                                }
                            ) { state in
                                VStack(spacing: 16) {
                                    hButton.LargeButton(type: .primary) {
                                        onSelected()
                                    } content: {
                                        hText(L10n.terminationButton, style: .standard)
                                    }
                                    .disabled(isCancelButtonDisabled(state: state))
                                }
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    .padding(.top, 16)
                }
        }
        .presentableStoreLensAnimation(.default)
    }

    private var displayInsuranceField: some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state.config
            }
        ) { config in
            if let config {
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
        }
    }

    private func displayTerminationDateField(isDeletion: Bool) -> some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state
            }
        ) { state in
            if isDeletion {
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
            } else if let terminationDateStep = state.terminationDateStep {
                hSection {
                    hFloatingField(
                        value: terminationDateStep.date?.displayDateDDMMMYYYYFormat
                            ?? L10n.terminationFlowDateFieldPlaceholder,
                        placeholder: L10n.terminationFlowDateFieldText,
                        onTap: {
                            store.send(.navigationAction(action: .openTerminationDatePickerScreen))
                        }
                    )
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.chevronDownSmall.image)
                    }
                }
            }
        }
    }

    private var displayImportantInformation: some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state.terminationDateStep?.date
            }
        ) { terminationDate in
            if terminationDate != nil {
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
                                        .foregroundColor(
                                            hColorScheme(light: hTextColor.primary, dark: hTextColor.negative)
                                        )
                                    Spacer()
                                    if hasAgreedToTerms {
                                        HStack {
                                            Image(uiImage: hCoreUIAssets.tick.image)
                                                .foregroundColor(
                                                    hColorScheme(light: hTextColor.negative, dark: hTextColor.primary)
                                                )
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
                                                    .strokeBorder(
                                                        hColorScheme(
                                                            light: hBorderColor.translucentTwo,
                                                            dark: hGrayscaleTranslucent.greyScaleTranslucent300Light
                                                        ),
                                                        lineWidth: 2
                                                    )
                                                    .animation(.easeInOut)
                                            )
                                            .hUseLightMode

                                    }
                                }
                                .background(
                                    Squircle.default()
                                        .fill(
                                            hColorScheme(
                                                light: hGrayscaleTranslucent.offWhiteTranslucentInverted,
                                                dark: hTextColor.primaryTranslucent
                                            )
                                        )
                                )
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if !hasAgreedToTerms {
                                hasAgreedToTerms = true
                            } else {
                                hasAgreedToTerms = false
                            }
                        }
                    }
                }
            }
        }
    }

    private func isCancelButtonDisabled(state: TerminationContractState) -> Bool {
        let hasSetTerminationDate = state.terminationDateStep?.date != nil
        return !state.isDeletion && (!hasSetTerminationDate || !hasAgreedToTerms)
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
