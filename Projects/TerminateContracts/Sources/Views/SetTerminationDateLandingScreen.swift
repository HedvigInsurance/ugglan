import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDateLandingScreen: View {
    @PresentableStore var store: TerminationContractStore
    @StateObject var vm = SetTerminationDateLandingScreenViewModel()
    let onSelected: () -> Void

    var body: some View {
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
                    title: .init(.standard, .title3, L10n.terminationFlowCancellationTitle, alignment: .leading),
                    subTitle: .init(
                        .standard,
                        .title3,
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
                                    onSelected()
                                } content: {
                                    hText(L10n.terminationButton, style: .standard)
                                }
                                .disabled(vm.isCancelButtonDisabled)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    .padding(.top, 16)
                }
        }
    }

    @ViewBuilder
    private var displayInsuranceField: some View {
        if let config = store.state.config {
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
                            Image(uiImage: hCoreUIAssets.lockSmall.image)
                                .frame(width: 24, height: 24)
                        }
                        .hFontSize(.standard)
                        .hFieldLockedState
                        .hWithoutDisabledColor
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
                hSection {
                    hFloatingField(
                        value: vm.terminationDate?.displayDateDDMMMYYYYFormat
                            ?? L10n.terminationFlowDateFieldPlaceholder,
                        placeholder: L10n.terminationFlowDateFieldText,
                        onTap: {
                            store.send(.navigationAction(action: .openTerminationDatePickerScreen))
                        }
                    )
                    .hFontSize(.standard)
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.chevronDownSmall.image)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var displayImportantInformation: some View {
        if vm.terminationDate != nil {
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
                                if vm.hasAgreedToTerms {
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
                        vm.hasAgreedToTerms.toggle()
                    }
                }
            }
        }
    }

    @hColorBuilder
    func getFillColor() -> some hColor {
        if vm.hasAgreedToTerms {
            hSignalColor.greenElement
        } else {
            hFillColor.opaqueOne
        }
    }
}

class SetTerminationDateLandingScreenViewModel: ObservableObject {
    @Published var isDeletion: Bool?
    @Published var hasAgreedToTerms: Bool = false
    @Published var isCancelButtonDisabled: Bool = true
    @Published var titleText: String = ""
    @Published var terminationDate: Date?
    private var cancellables = Set<AnyCancellable>()
    init() {
        let terminationStore: TerminationContractStore = globalPresentableStoreContainer.get()
        terminationStore.stateSignal.plain().publisher
            .map({ $0.terminationDateStep?.date })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] date in
                self?.terminationDate = date
            }
            .store(in: &cancellables)

        terminationStore.stateSignal.plain().publisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] state in
                let isDeletion: Bool? = {
                    if state.terminationDeleteStep != nil {
                        return true
                    }
                    if state.terminationDateStep != nil {
                        return false
                    }
                    return nil
                }()
                withAnimation {
                    self?.isDeletion = isDeletion
                    self?.titleText =
                        isDeletion ?? false ? L10n.terminationFlowConfirmInformation : L10n.terminationDateText
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3($terminationDate, $isDeletion, $hasAgreedToTerms)
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] (date, isDeletion, aggreedToTerms) in
                let hasSetTerminationDate = date != nil
                withAnimation {
                    self?.isCancelButtonDisabled = !(isDeletion ?? false) && (!hasSetTerminationDate || !aggreedToTerms)
                }
            }
            .store(in: &cancellables)
    }
}

#Preview{
    SetTerminationDateLandingScreen(onSelected: {})
}
