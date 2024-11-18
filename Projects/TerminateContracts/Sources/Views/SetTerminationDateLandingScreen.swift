import Combine
import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDateLandingScreen: View {
    @StateObject var vm = SetTerminationDateLandingScreenViewModel()
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init(
        terminationNavigationVm: TerminationFlowNavigationViewModel
    ) {
        self.terminationNavigationVm = terminationNavigationVm
    }

    var body: some View {
        Group {
            if vm.isDeletion == nil {
                HStack {
                    DotsActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.top)
                .useDarkColor
            } else {
                hForm {}
                    .hDisableScroll
                    .hFormTitle(
                        title: .init(
                            .small,
                            .heading2,
                            L10n.terminationFlowCancellationTitle,
                            alignment: .leading
                        ),
                        subTitle: .init(
                            .small,
                            .heading2,
                            vm.titleText
                        )
                    )
                    .hFormAttachToBottom {
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                displayInsuranceField
                                displayTerminationDateField
                                displayImportantInformation
                            }

                            hSection {
                                VStack(spacing: 16) {
                                    hButton.LargeButton(type: .primary) {
                                        terminationNavigationVm.isConfirmTerminationPresented = true
                                    } content: {
                                        hText(L10n.terminationButton, style: .body1)
                                    }
                                    .disabled(
                                        vm.isCancelButtonDisabled(
                                            terminationDate: terminationNavigationVm.terminationDateStepModel?.date
                                        )
                                    )
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        }
                        .padding(.vertical, 16)
                    }
            }
        }
        .onAppear {
            vm.terminationDeleteStep = terminationNavigationVm.terminationDeleteStepModel
            vm.terminationDateStep = terminationNavigationVm.terminationDateStepModel
        }
    }

    @ViewBuilder
    private var displayInsuranceField: some View {
        if let config = terminationNavigationVm.config {
            hSection {
                hRow {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(config.contractDisplayName)
                        hText(config.contractExposureName, style: .label)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                }
                .verticalPadding(10.5)
            }
        }
    }

    @ViewBuilder
    private var displayTerminationDateField: some View {
        if let isDeletion = vm.isDeletion {
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
                            hCoreUIAssets.lock.view
                                .frame(width: 24, height: 24)
                        }
                        .hBackgroundOption(option: [.locked, .withoutDisabled])
                        .disabled(true)

                        InfoCard(
                            text:
                                L10n.terminationFlowDeletionInfoCard,
                            type: .info
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            } else {
                DropdownView(
                    value: terminationNavigationVm.terminationDateStepModel?.date?.displayDateDDMMMYYYYFormat
                        ?? L10n.terminationFlowDateFieldPlaceholder,
                    placeHolder: L10n.terminationFlowDateFieldText,
                    onTap: {
                        terminationNavigationVm.isDatePickerPresented = true
                    }
                )
                .hFieldSize(.medium)
            }
        }
    }

    @ViewBuilder
    private var displayImportantInformation: some View {
        if terminationNavigationVm.terminationDateStepModel?.date != nil {
            hSection {
                hRow {
                    VStack(spacing: 16) {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                hText(L10n.terminationFlowImportantInformationTitle)
                                hText(
                                    L10n.terminationFlowImportantInformationText,
                                    style: .label
                                )
                                .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }

                        HStack {
                            hRow {
                                hText(L10n.terminationFlowIUnderstandText)
                                    .foregroundColor(
                                        hColorScheme(light: hTextColor.Opaque.primary, dark: hTextColor.Opaque.negative)
                                    )
                                Spacer()
                                if vm.hasAgreedToTerms {
                                    HStack {
                                        hCoreUIAssets.checkmark.view
                                            .foregroundColor(
                                                hColorScheme(
                                                    light: hTextColor.Opaque.negative,
                                                    dark: hTextColor.Opaque.primary
                                                )
                                            )
                                    }
                                    .frame(width: 24, height: 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(hSignalColor.Green.element)
                                    )
                                } else {
                                    Circle()
                                        .fill(hBackgroundColor.clear)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(
                                                    hBorderColor.secondary,
                                                    lineWidth: 2
                                                )
                                                .animation(.easeInOut, value: UUID())
                                        )
                                        .colorScheme(.light)
                                        .hUseLightMode

                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: .cornerRadiusS)
                                    .fill(
                                        hFillColor.Translucent.negative
                                    )
                            )
                        }
                        .colorScheme(.light)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.hasAgreedToTerms.toggle()
                    }
                }
            }
        }
    }

    @hColorBuilder
    func getFillColor() -> some hColor {
        if vm.hasAgreedToTerms {
            hSignalColor.Green.element
        } else {
            hSurfaceColor.Opaque.primary
        }
    }
}

class SetTerminationDateLandingScreenViewModel: ObservableObject {
    @Published var isDeletion: Bool?
    @Published var hasAgreedToTerms: Bool = false
    @Published var titleText: String = ""

    @Published var terminationDeleteStep: TerminationFlowDeletionNextModel? {
        didSet {
            checkDeletion()
        }
    }
    @Published var terminationDateStep: TerminationFlowDateNextStepModel? {
        didSet {
            checkDeletion()
        }
    }

    func isCancelButtonDisabled(terminationDate: Date?) -> Bool {
        let hasSetTerminationDate = terminationDate != nil
        return !(isDeletion ?? false) && (!hasSetTerminationDate || !hasAgreedToTerms)
    }

    private func checkDeletion() {
        isDeletion = {
            if terminationDeleteStep != nil {
                return true
            }
            if terminationDateStep != nil {
                return false
            }
            return nil
        }()

        withAnimation {
            self.isDeletion = isDeletion
            self.titleText =
                isDeletion ?? false ? L10n.terminationFlowConfirmInformation : L10n.terminationDateText
        }
    }
}

#Preview {
    SetTerminationDateLandingScreen(
        terminationNavigationVm: .init(initialStep: nil, context: "", progress: nil, previousProgress: nil)
    )
}
