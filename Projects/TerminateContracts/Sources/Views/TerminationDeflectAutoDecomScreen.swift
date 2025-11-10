import SwiftUI
import hCore
import hCoreUI

struct TerminationDeflectAutoDecomScreen: View {
    @EnvironmentObject var router: Router
    @ObservedObject var vm: TerminationDeflectAutoDecomViewModel
    let model: TerminationFlowDeflectAutoDecomModel
    init(
        model: TerminationFlowDeflectAutoDecomModel,
        navigation: TerminationFlowNavigationViewModel

    ) {
        self.model = model
        self.vm = .init(navigationVM: navigation)
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hSection {
                    subtitleLabel(for: L10n.terminationFlowAutoDecomInfo)
                }
                coveredView
                costView
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.terminationFlowAutoDecomTitle,
                alignment: .leading
            )
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    infoView
                    bottomButtons
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .trackErrorState(for: $vm.state)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.generalRetry,
                    buttonAction: { [weak vm] in
                        vm?.state = .success
                    }
                )
            )
        )
    }

    private var coveredView: some View {
        hSection {
            headerLabel(for: L10n.terminationFlowAutoDecomCoveredTitle)
            subtitleLabel(for: L10n.terminationFlowAutoDecomCoveredInfo)
        }
        .accessibilityElement(children: .combine)
    }
    private var costView: some View {
        hSection {
            headerLabel(for: L10n.terminationFlowAutoDecomCostsTitle)
            subtitleLabel(for: L10n.terminationFlowAutoDecomCostsInfo)
        }
        .accessibilityElement(children: .combine)
    }

    private var infoView: some View {
        InfoCard(text: L10n.terminationFlowAutoDecomNotification, type: .info)
    }

    private var bottomButtons: some View {
        VStack(spacing: .padding8) {
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.terminationFlowIUnderstandText)
            ) { [weak router] in
                router?.dismiss()
            }
            .disabled(vm.state == .loading)

            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.terminationButton)
            ) {
                Task { [weak vm] in
                    await vm?.continueWithTermination()
                }
            }
            .hButtonIsLoading(vm.state == .loading)
        }
    }

    private func headerLabel(for text: String) -> some View {
        hText(text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subtitleLabel(for text: String) -> some View {
        hText(text)
            .foregroundColor(hTextColor.Translucent.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var navigation = TerminationFlowNavigationViewModel(
        configs: [],
        terminateInsuranceViewModel: nil
    )
    TerminationDeflectAutoDecomScreen(model: .init(), navigation: navigation)
        .environmentObject(Router())
}

@MainActor
class TerminationDeflectAutoDecomViewModel: ObservableObject {
    @Published var state: ProcessingState = .success
    private let terminateContractsService = TerminateContractsService()
    weak var navigationVM: TerminationFlowNavigationViewModel?
    init(navigationVM: TerminationFlowNavigationViewModel) {
        self.navigationVM = navigationVM
    }

    func continueWithTermination() async {
        if let context = navigationVM?.currentContext {
            withAnimation {
                state = .loading
            }
            do {
                let step = try await terminateContractsService.sendContinueAfterDecom(terminationContext: context)
                navigationVM?.navigate(data: step, fromSelectInsurance: false)
                withAnimation {
                    state = .success
                }
            } catch let exp {
                withAnimation {
                    state = .error(errorMessage: exp.localizedDescription)
                }
            }
        }
    }
}
