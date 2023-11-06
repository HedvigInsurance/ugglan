import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct AddCampaingCodeView: View {
    @StateObject var vm = AddCampaingCodeViewModel()
    var body: some View {
        if vm.codeAdded {
            ZStack(alignment: .center) {
                textInput
                hForm {
                    SuccessScreen(title: "Discount added")
                }
                .hFormContentPosition(.center)
                .hDisableScroll
                .introspectViewController { vc in
                    vc.view.backgroundColor = .brand(.primaryBackground())
                    if #available(iOS 16.0, *) {
                        for i in 1...3 {
                            if vc.presentingViewController != nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 + Double(i) * 0.05) {
                                    if let vc = vc as UIViewController? {
                                        vc.sheetPresentationController?.invalidateDetents()
                                        vc.sheetPresentationController?
                                            .animateChanges {
                                                vc.title = nil
                                                vc.navigationController?.setNavigationBarHidden(true, animated: true)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            textInput
        }
    }

    var textInput: some View {
        TextInputView(vm: vm.inputVm)
    }
}

class AddCampaingCodeViewModel: ObservableObject {
    let inputVm: TextInputViewModel
    var errorMessage: String?
    @Published var codeAdded: Bool = false
    @Inject var campaignsService: hCampaignsService
    init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        inputVm = TextInputViewModel(
            masking: .init(type: .none),
            input: "",
            title: "Add campaign code",
            dismiss: { [weak store] in
                store?.send(.navigation(to: .goBack))
            }
        )

        inputVm.onSave = { [weak self, weak store] text in
            try await self?.campaignsService.add(code: text)
            store?.send(.fetchDiscountsData)
            await self?.onSuccessAdd()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak store] in
                store?.send(.navigation(to: .goBack))
            }
        }
    }

    @MainActor
    func onSuccessAdd() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            codeAdded = true
        }
    }
}

extension AddCampaingCodeView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: AddCampaingCodeView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .goBack = navigateTo {
                    PopJourney()
                }
            }
        }
        .configureTitle("Add campaign")
    }
}

struct AddCampaingCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsServiceDemo() })
        return AddCampaingCodeView()
    }
}
