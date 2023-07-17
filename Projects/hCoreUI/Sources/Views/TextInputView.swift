import Flow
import Foundation
import Presentation
import SwiftUI
import hCore

public struct TextInputView: View {
    @ObservedObject private var vm: TextInputViewModel
    public init(
        vm: TextInputViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        hForm {}
            .hFormAttachToBottom {
                VStack(spacing: 16) {
                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .none),
                            value: $vm.input,
                            equals: $vm.type,
                            focusValue: .textField,
                            placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
                            error: $vm.error
                        )
                        .disabled(vm.isLoading)

                    }
                    .sectionContainerStyle(.transparent)
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButtonPrimary {
                                withAnimation { [weak vm] in
                                    vm?.save()
                                }
                            } content: {
                                hText(L10n.generalSaveButton, style: .body)
                            }
                            hButton.LargeButtonText {
                                vm.dismiss()
                            } content: {
                                hText(L10n.generalCancelButton, style: .body)
                            }
                        }
                    }
                    .hButtonIsLoading(vm.isLoading)
                    .sectionContainerStyle(.transparent)
                    .padding(.bottom, 16)
                }
            }
    }
    enum InputViewFocus: hTextFieldFocusStateCompliant {
        static var last: InputViewFocus {
            return InputViewFocus.textField
        }

        var next: InputViewFocus? {
            return nil
        }

        case textField
    }
}

public class TextInputViewModel: ObservableObject {
    @Published var input: String
    @Published var error: String?
    @Published var isLoading: Bool = false
    @Published var type: TextInputView.InputViewFocus? = .textField

    let saveButtonDisposeBag = DisposeBag()
    let title: String
    let onSave: (String) -> FiniteSignal<String?>
    var dismiss: () -> Void = {}

    public init(
        input: String,
        title: String,
        onSave: @escaping (String) -> FiniteSignal<String?>,
        dismiss: @escaping () -> Void
    ) {
        self.input = input
        self.title = title
        self.onSave = onSave
        self.dismiss = dismiss
    }

    func save() {
        error = nil
        isLoading = true
        saveButtonDisposeBag.dispose()
        saveButtonDisposeBag += onSave(input)
            .onValue { [weak self] error in
                if let error {
                    self?.error = error
                } else {
                    self?.dismiss()
                }
                self?.isLoading = false
                self?.type = .textField
                self?.saveButtonDisposeBag.dispose()
            }
    }

    deinit {
        let ss = ""
    }
}
