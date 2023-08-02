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
                            placeholder: vm.title,
                            error: $vm.error
                        )
                        .disabled(vm.isLoading)

                    }
                    .sectionContainerStyle(.transparent)
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButtonPrimary {
                                Task { [weak vm] in
                                    withAnimation {
                                        vm?.isLoading = true
                                    }
                                    await vm?.save()
                                    withAnimation {
                                        vm?.isLoading = false
                                    }
                                }
                            } content: {
                                hText(L10n.generalSaveButton, style: .body)
                            }
                            hButton.LargeButtonGhost {
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

    let title: String
    public var onSave: ((String) async throws -> Void)?
    var dismiss: () -> Void = {}

    public init(
        input: String,
        title: String,
        dismiss: @escaping () -> Void
    ) {
        self.input = input
        self.title = title
        self.dismiss = dismiss
    }

    func save() async {
        DispatchQueue.main.async { [weak self] in
            self?.type = nil
            self?.error = nil
            self?.isLoading = true
        }
        do {
            try await onSave?(input)
        } catch let error {
            DispatchQueue.main.async { [weak self] in
                self?.error = error.localizedDescription
            }
        }
    }
}
