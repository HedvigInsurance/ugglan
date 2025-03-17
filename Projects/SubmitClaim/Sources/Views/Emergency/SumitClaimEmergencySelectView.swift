import SwiftUI
import hCore
import hCoreUI

struct SumitClaimEmergencySelectView: View {
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @StateObject var vm = SumitClaimEmergencySelectViewModel()
    @State var selectedValue: Bool = true
    let title: String

    init(
        title: String
    ) {
        self.title = title
    }
    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    title,
                    alignment: .leading
                )
            )
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
                        .hButtonIsLoading(vm.state == .loading)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .claimErrorTrackerForState($vm.state)
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
                    .hButtonTakeFullWidth(true)
                } else {
                    hButton.MediumButton(type: .secondary) {
                        withAnimation(.spring()) {
                            selectedValue = option.value
                        }
                    } content: {
                        hText(option.displayName)
                    }
                    .hButtonTakeFullWidth(true)
                }
            }
        }
    }
}

@MainActor
public class SumitClaimEmergencySelectViewModel: ObservableObject {
    private let service = SubmitClaimService()
    @Published var state: ProcessingState = .success

    @MainActor
    func emergencyConfirmRequest(context: String, isEmergency: Bool) async -> SubmitClaimStepResponse? {
        withAnimation {
            state = .loading
        }
        do {
            let data = try await service.emergencyConfirmRequest(isEmergency: isEmergency, context: context)
            withAnimation {
                state = .success
            }
            return data
        } catch let exception {
            withAnimation {
                state = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}

struct SumitClaimEmergencySelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        SumitClaimEmergencySelectView(title: L10n.submitClaimEmergencyTitle)
    }
}
