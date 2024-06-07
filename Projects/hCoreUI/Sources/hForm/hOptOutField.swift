import Flow
import SwiftUI
import hCore

public class hOptOutFieldNavigationViewModel: ObservableObject {
    @Published var isFieldPresented: hOptOutFieldViewModel?
}

public struct hOptOutField: View {
    @ObservedObject var config: HOptOutFieldConfig
    private let onContinue: (_ value: String) -> Void
    @Binding private var value: String
    @State private var animate = false
    @Binding var error: String?
    @State var selected: String = ""

    @StateObject var hOptOutFieldViewModel = hOptOutFieldNavigationViewModel()
    @EnvironmentObject var router: Router

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { true },
            set: { _ in }
        )
    }

    public init(
        config: HOptOutFieldConfig,
        value: Binding<String>,
        error: Binding<String?>? = nil,
        onContinue: @escaping (_ value: String) -> Void = { _ in }
    ) {
        self.config = config
        self._value = value
        self._error = error ?? Binding.constant(nil)
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hFieldLabel(
                placeholder: config.placeholder,
                animate: $animate,
                error: $error,
                shouldMoveLabel: shouldMoveLabel
            )
            .disabled(config.notSure)

            HStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    hText(displayLabel, style: .title3)
                        .foregroundColor(getLabelColor)
                }
                .fixedSize(horizontal: false, vertical: true)
                .findScrollView { scrollView in
                    scrollView.bounces = false
                }
                Toggle(isOn: $config.notSure.animation(.default)) {
                    HStack(spacing: 8) {
                        Spacer()
                        hText(L10n.optoutFieldPlaceholder, style: .body)
                            .foregroundColor(getToggleTextColor)
                            .fixedSize()
                    }
                }
                .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
                .contentShape(Rectangle())
                .fixedSize()
            }
        }
        .padding(.top, 11)
        .padding(.bottom, 10)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            if !config.notSure {
                showPriceInputView()
            }
        }
        .detent(
            item: $hOptOutFieldViewModel.isFieldPresented,
            style: .height
        ) { hOptOutFieldModel in
            PriceInputScreen(vm: hOptOutFieldModel)
        }
    }

    var displayLabel: String {
        if config.notSure {
            return L10n.genericUnknown
        } else {
            return value != "" ? value : L10n.optoutFieldEnterHere
        }
    }

    @hColorBuilder
    var getLabelColor: some hColor {
        if config.notSure {
            hTextColor.Opaque.tertiary
        } else if value != "" {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }

    @hColorBuilder
    var getToggleTextColor: some hColor {
        if config.notSure {
            hTextColor.Opaque.primary
        } else {
            hTextColor.secondaryTranslucent
        }
    }

    private func showPriceInputView() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        hOptOutFieldViewModel.isFieldPresented = .init(
            config: config,
            continueAction: continueAction,
            cancelAction: cancelAction,
            onSave: { value in
                self.value = value
            },
            purchasePrice: value
        )
        continueAction.execute = {
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
            self.onContinue(value)
            router.dismiss()
        }
        cancelAction.execute = {
            router.dismiss()
        }
    }

    public class HOptOutFieldConfig: ObservableObject {
        let placeholder: String
        let currency: String
        @Published var notSure = false

        public init(
            placeholder: String,
            currency: String
        ) {
            self.placeholder = placeholder
            self.currency = currency
        }
    }
}

struct PriceInputScreen: View {
    private var vm: hOptOutFieldViewModel
    @State private var type: hOptOutFieldType? = .purchasePrice

    init(
        vm: hOptOutFieldViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        hForm {
            hSection {
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: vm.$purchasePrice,
                    equals: $type,
                    focusValue: .purchasePrice,
                    placeholder: vm.config.placeholder,
                    suffix: vm.config.currency
                )
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        UIApplication.dismissKeyboard()
                        vm.onSave(vm.purchasePrice)
                        vm.continueAction.execute()
                    } content: {
                        hText(L10n.generalSaveButton, style: .body)
                    }
                    hButton.LargeButton(type: .ghost) {
                        vm.cancelAction.execute()
                    } content: {
                        hText(L10n.generalNotSure, style: .body)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .introspectScrollView { scrollView in
            scrollView.keyboardDismissMode = .interactive
        }
    }
}

#Preview{
    hForm {
        @State var value1: String = "4500"
        @State var value2: String = ""

        VStack(spacing: 5) {
            hOptOutField(
                config: .init(
                    placeholder: "Purchase price",
                    currency: "SEK"
                ),
                value: $value1
            )

            hOptOutField(
                config: .init(
                    placeholder: "Purchase price",
                    currency: "SEK"
                ),
                value: $value2
            )
        }
    }
}

enum hOptOutFieldType: hTextFieldFocusStateCompliant {
    static var last: hOptOutFieldType {
        return hOptOutFieldType.purchasePrice
    }

    var next: hOptOutFieldType? {
        switch self {
        case .purchasePrice:
            return nil
        }
    }

    case purchasePrice
}

struct hOptOutFieldViewModel: Identifiable, Equatable {
    static func == (lhs: hOptOutFieldViewModel, rhs: hOptOutFieldViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    var id: String?
    let continueAction: ReferenceAction
    let cancelAction: ReferenceAction
    let config: hOptOutField.HOptOutFieldConfig
    var onSave: (String) -> Void

    @State var purchasePrice: String

    init(
        config: hOptOutField.HOptOutFieldConfig,
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        onSave: @escaping (String) -> Void,
        purchasePrice: String
    ) {
        self.config = config
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self.onSave = onSave
        self.purchasePrice = purchasePrice
    }
}
