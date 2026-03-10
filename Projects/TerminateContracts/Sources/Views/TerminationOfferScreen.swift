import Environment
import SwiftUI
import hCore
import hCoreUI

struct TerminationOfferScreen: View {
    @EnvironmentObject var router: Router
    @ObservedObject var vm: TerminationOfferViewModel
    let model: TerminationFlowOfferStepModel

    init(
        model: TerminationFlowOfferStepModel,
        navigation: TerminationFlowNavigationViewModel
    ) {
        self.model = model
        self.vm = .init(navigationVM: navigation)
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hSection {
                    InfoCard(text: model.description, type: .campaign)
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
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: model.buttonTitle)
                    ) {
                        handleCTATap()
                    }
                    .disabled(vm.state == .loading)

                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: model.skipButtonTitle)
                    ) {
                        Task { [weak vm] in
                            await vm?.skipOffer()
                        }
                    }
                    .hButtonIsLoading(vm.state == .loading)
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

    private func handleCTATap() {
        switch model.action {
        case .updateAddress:
            router.dismiss()
            var url = Environment.current.deepLinkUrls.last!
            url.appendPathComponent(DeepLink.moveContract.rawValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .openDeepLink, object: url)
            }
        case .changeTier:
            break
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var navigation = TerminationFlowNavigationViewModel(
        configs: [],
        terminateInsuranceViewModel: nil
    )
    TerminationOfferScreen(
        model: .init(
            title: "Erbjudande för dig",
            description: "Flytta enkelt! Du får 20% rabatt de första 6 månaderna på ditt nya boende.",
            buttonTitle: "Få ett prisförslag",
            skipButtonTitle: "Hoppa över",
            action: .updateAddress
        ),
        navigation: navigation
    )
    .environmentObject(Router())
}

@MainActor
class TerminationOfferViewModel: ObservableObject {
    @Published var state: ProcessingState = .success
    private let terminateContractsService = TerminateContractsService()
    weak var navigationVM: TerminationFlowNavigationViewModel?

    init(navigationVM: TerminationFlowNavigationViewModel) {
        self.navigationVM = navigationVM
    }

    func skipOffer() async {
        if let context = navigationVM?.currentContext {
            withAnimation {
                state = .loading
            }
            do {
                let step = try await terminateContractsService.skipOfferStep(terminationContext: context)
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
