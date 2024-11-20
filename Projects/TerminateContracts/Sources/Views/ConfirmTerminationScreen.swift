import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @State private var isHidden = false
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel
    @EnvironmentObject var confirmTerminationVm: ConfirmTerminationViewModel

    init() {}

    var body: some View {
        GenericErrorView(
            title: L10n.General.areYouSure,
            description: terminationText,
            attachContentToTheBottom: true
        )
        .hErrorViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.terminationFlowConfirmButton,
                        buttonAction: {
                            if terminationNavigationVm.isDeletion {
                                Task {
                                    let step = await confirmTerminationVm.sendConfirmDelete(
                                        context: terminationNavigationVm.currentContext ?? "",
                                        model: terminationNavigationVm.terminationDeleteStepModel
                                    )

                                    if let step {
                                        terminationNavigationVm.navigate(data: step, fromSelectInsurance: false)
                                    }
                                }
                            } else {
                                terminationNavigationVm.isProcessingPresented = true

                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    Task {
                                        let step = await confirmTerminationVm.sendTerminationDate(
                                            inputDateToString: terminationNavigationVm.terminationDateStepModel?.date?
                                                .localDateString ?? "",
                                            context: terminationNavigationVm.currentContext ?? ""
                                        )

                                        if let step {
                                            terminationNavigationVm.navigate(data: step, fromSelectInsurance: false)
                                        }
                                    }
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isHidden = true
                            }
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        terminationNavigationVm.isConfirmTerminationPresented = false
                    }
                )
            )
        )
        .hExtraTopPadding
        .hDisableScroll
        .hide($isHidden)
    }

    var terminationText: String {
        if terminationNavigationVm.isDeletion {
            return L10n.terminationFlowConfirmation
        }
        return L10n.terminationFlowConfirmationSubtitleTermination(
            terminationNavigationVm.terminationDateStepModel?.date?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

class ConfirmTerminationViewModel: ObservableObject {
    @Inject private var service: TerminateContractsClient
    @Published var viewState: ProcessingState = .loading

    @MainActor
    public func sendConfirmDelete(
        context: String,
        model: TerminationFlowDeletionNextModel?
    ) async -> TerminateStepResponse? {
        withAnimation {
            viewState = .loading
        }
        do {
            let data = try await service.sendConfirmDelete(terminationContext: context, model: model)
            withAnimation {
                viewState = .success
            }
            return data
        } catch let error {
            withAnimation {
                self.viewState = .error(
                    errorMessage: error.localizedDescription
                )
            }
        }
        return nil
    }

    @MainActor
    public func sendTerminationDate(inputDateToString: String, context: String) async -> TerminateStepResponse? {
        withAnimation {
            viewState = .loading
        }
        do {
            let data = try await service.sendTerminationDate(
                inputDateToString: inputDateToString,
                terminationContext: context
            )
            withAnimation {
                viewState = .success
            }
            return data
        } catch let error {
            withAnimation {
                self.viewState = .error(
                    errorMessage: error.localizedDescription
                )
            }
        }
        return nil
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmTerminationScreen()
    }
}
