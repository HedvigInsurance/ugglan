import SwiftUI
import hCore
import hCoreUI

struct SumitClaimEmergencySelectView: View {
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @StateObject var vm = SumitClaimEmergencySelectViewModel()
    @State var selectedValue: Bool = true
    @State var isLoading: Bool = false
    let title: () -> String

    init(
        title: @escaping () -> String
    ) {
        self.title = title
    }
    var body: some View {
        hForm {}
            .hFormTitle(title: .init(.small, .displayXSLong, title()))
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 16) {
                        buttonView()
                        hButton.LargeButton(type: .primary) {
                            Task {
                                let step = await vm.emergencyConfirmRequest(
                                    context: claimsNavigationVm.currentClaimContext ?? "",
                                    isEmergency: selectedValue
                                )

                                if let step {
                                    claimsNavigationVm.navigate(data: step)
                                }
                            }
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        .hButtonIsLoading(isLoading)
                    }
                    .padding(.bottom, .padding32)
                }
                .sectionContainerStyle(.transparent)
            }
            .hDisableScroll
    }

    @ViewBuilder
    func buttonView() -> some View {
        let confirmEmergency = claimsNavigationVm.emergencyConfirmModel
        HStack(spacing: 8) {
            ForEach(confirmEmergency?.options ?? [], id: \.displayName) { option in
                if option.value == selectedValue {
                    hButton.MediumButton(type: .primaryAlt) {
                        withAnimation(.spring()) {
                            selectedValue = option.value
                        }
                    } content: {
                        hText(option.displayName)
                            .foregroundColor(
                                hColorScheme(light: hTextColor.Opaque.primary, dark: hTextColor.Opaque.negative)
                            )
                    }
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    hButton.MediumButton(type: .secondary) {
                        withAnimation(.spring()) {
                            selectedValue = option.value
                        }
                    } content: {
                        hText(option.displayName)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

public class SumitClaimEmergencySelectViewModel: ObservableObject {
    @Inject private var service: SubmitClaimClient

    @MainActor
    func emergencyConfirmRequest(context: String, isEmergency: Bool) async -> SubmitClaimStepResponse? {
        do {
            let data = try await service.emergencyConfirmRequest(isEmergency: isEmergency, context: context)
            return data
        } catch let exception {}
        return nil
    }
}

struct SumitClaimEmergencySelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        SumitClaimEmergencySelectView {
            return L10n.submitClaimEmergencyTitle
        }
    }
}