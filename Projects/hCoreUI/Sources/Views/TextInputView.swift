import Foundation
import SwiftUI
import hCore

public struct TextInputView: View {
    @ObservedObject private var vm: TextInputViewModel
    let dismissAction: (() -> Void)?

    public init(
        vm: TextInputViewModel,
        dismissAction: (() -> Void)? = nil
    ) {
        self.vm = vm
        self.dismissAction = dismissAction
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
                            hText(L10n.generalSaveButton, style: .body1)
                        }
                        .hButtonIsLoading(vm.isLoading)

                        hCancelButton {
                            if let dismissAction = dismissAction?() {
                                dismissAction
                            } else {
                                Task { [weak vm] in
                                    await vm?.dismiss()
                                }
                            }
                        }
                        .disabled(vm.isLoading)
                    }
                }

                .padding(.vertical, .padding16)
            }
        }
        .hFormContentPosition(.compact)
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
    @Published public var input: String
    @Published var error: String?
    @Published var isLoading: Bool = false
    @Published var type: TextInputView.InputViewFocus? = .textField
    let masking: Masking

    let title: String
    public var onSave: ((String) async throws -> Void)?
    public var onDismiss: (() async throws -> Void)?

    public init(
        masking: Masking,
        input: String,
        title: String
    ) {
        self.masking = masking
        self.input = input
        self.title = title
    }

    @MainActor
    public func save() async {
        withAnimation {
            self.type = nil
            self.error = nil
            self.isLoading = true
        }
        do {
            try await onSave?(input)
        } catch let error {
            withAnimation {
                self.error = error.localizedDescription
            }
        }
    }

    @MainActor
    func dismiss() async {
        do {
            try await onDismiss?()
        } catch _ {}
    }
}
