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
                    subtitleLabel(for: model.message)
                }
                ForEach(model.explanations, id: \.self) { explanation in
                    sectionView(for: explanation.title, and: explanation.text)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                model.title,
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

    private func sectionView(for title: String?, and subtitle: String) -> some View {
        hSection {
            if let title {
                headerLabel(for: title)
            }
            subtitleLabel(for: subtitle)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var infoView: some View {
        if let info = model.info {
            InfoCard(text: info, type: .info)
                .accessibilitySortPriority(1)
        }
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
    TerminationDeflectAutoDecomScreen(
        model: .init(
            message: "message",
            title: "title",
            explanations: [.init(title: "title", text: "text")],
            info: "info"
        ),
        navigation: navigation
    )
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
