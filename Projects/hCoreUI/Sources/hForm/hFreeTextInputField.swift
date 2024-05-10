import Flow
import SwiftUI
import hCore

class hFreeTextInputFieldNavigationViewModel: ObservableObject {
    @Published var isFieldPresented: FreeTextInputViewModel?
}

public struct hFreeTextInputField: View {
    private var placeholder: String
    @State private var animate = false
    private var selectedValue: String?
    @Binding var error: String?
    @State private var value: String
    @State private var disposeBag = DisposeBag()
    private let onContinue: (_ text: String) -> Void
    private let infoCardText: String?

    @StateObject var freeTextInputNavigationModel = hFreeTextInputFieldNavigationViewModel()
    @EnvironmentObject var router: Router

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { !(selectedValue?.isEmpty ?? true) },
            set: { _ in }
        )
    }

    public init(
        selectedValue: String?,
        placeholder: String? = nil,
        error: Binding<String?>? = nil,
        onContinue: @escaping (_ text: String) -> Void = { _ in },
        infoCardText: String? = nil
    ) {
        self.placeholder = placeholder ?? ""
        self.selectedValue = selectedValue
        self._error = error ?? Binding.constant(nil)
        self.onContinue = onContinue
        self.value = ""
        self.infoCardText = infoCardText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hFloatingField(value: selectedValue ?? "", placeholder: placeholder) {
                showFreeTextField()
            }
            .hWithoutFixedHeight
        }
        .detent(
            item: $freeTextInputNavigationModel.isFieldPresented,
            style: .height
        ) { freeTextPickerVm in
            freeTextInputView(vm: freeTextPickerVm)
                .embededInNavigation(options: .largeNavigationBar)
                .configureTitle(placeholder)
        }
    }

    private func showFreeTextField() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        value = selectedValue ?? ""

        freeTextInputNavigationModel.isFieldPresented = .init(
            continueAction: continueAction,
            cancelAction: cancelAction,
            value: $value,
            infoCardText: infoCardText
        )

        continueAction.execute = {
            self.onContinue(value)
            router.dismiss()
        }
        cancelAction.execute = {
            router.dismiss()
        }
    }

    private struct freeTextInputView: View {
        private let vm: FreeTextInputViewModel

        init(
            vm: FreeTextInputViewModel
        ) {
            self.vm = vm
        }

        public var body: some View {
            hForm {
                VStack(spacing: 16) {
                    VStack {
                        hTextField(
                            masking: Masking(type: .none),
                            value: vm.$value,
                            placeholder: L10n.textInputFieldPlaceholder
                        )
                        .hTextFieldOptions([.useLineBreak, .minimumHeight(height: 96)])
                        Spacer()
                        hText("\(vm.value.count)/\(vm.maxCharacters)", style: .standardSmall)
                            .foregroundColor(getTextColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding([.horizontal, .top], 16)
                    .padding(.bottom, 12)
                    .background(
                        Squircle.default()
                            .fill(hFillColor.opaqueOne)
                    )
                    if let infoCardText = vm.infoCardText {
                        InfoCard(text: infoCardText, type: .info)
                    }
                }
                .padding(.horizontal, 16)
            }
            .hFormAttachToBottom {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        vm.continueAction.execute()
                    } content: {
                        hText(L10n.generalSaveButton)
                    }
                    .disabled(vm.value.count > vm.maxCharacters)
                    hButton.LargeButton(type: .ghost) {
                        vm.cancelAction.execute()
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }

        @hColorBuilder
        var getTextColor: some hColor {
            if vm.value.count < vm.maxCharacters {
                hTextColor.tertiary
            } else {
                hSignalColor.redElement
            }
        }
    }
}

struct FreeTextInputViewModel: Equatable, Identifiable {
    static func == (lhs: FreeTextInputViewModel, rhs: FreeTextInputViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    var id: String?

    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var value: String
    let maxCharacters = 140
    let infoCardText: String?

    init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        infoCardText: String? = nil
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._value = value
        self.infoCardText = infoCardText
    }
}

#Preview{
    VStack(spacing: 4) {
        hFreeTextInputField(selectedValue: "", placeholder: "Type of damage")
        hFreeTextInputField(selectedValue: "value", placeholder: "placeholder")
    }
}
