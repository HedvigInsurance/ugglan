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
        hForm {
            VStack(spacing: 0) {
                hSection {
                    hFloatingTextField(
                        masking: vm.masking,
                        value: $vm.input,
                        equals: $vm.type,
                        focusValue: .textField,
                        placeholder: vm.title,
                        error: $vm.error
                    )
                    .disabled(vm.isLoading)
                }
                hSection {
                    VStack(spacing: 8) {
                        hButton.LargeButton(type: .primary) {
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
                        hButton.LargeButton(type: .ghost) {
                            vm.dismiss()
                        } content: {
                            hText(L10n.generalCancelButton, style: .body)
                        }
                    }
                }
                .hButtonIsLoading(vm.isLoading)
                .padding(.vertical, 16)
            }
        }
        .hDisableScroll
        .sectionContainerStyle(.transparent)
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
    let masking: Masking

    let title: String
    public var onSave: ((String) async throws -> Void)?
    var dismiss: () -> Void = {}

    public init(
        masking: Masking,
        input: String,
        title: String,
        dismiss: @escaping () -> Void
    ) {
        self.masking = masking
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
