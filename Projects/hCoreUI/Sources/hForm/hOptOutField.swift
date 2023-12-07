import Flow
import Presentation
import SwiftUI
import hCore

public struct hOptOutField: View {
    private var placeholder: String
    @State private var value: String = ""
    @State private var animate = false
    @Binding var error: String?
    private let onContinue: (_ value: String) -> Void

    @State var selected: String = ""
    @State var notSure = false
    @State private var disposeBag = DisposeBag()

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { true },
            set: { _ in }
        )
    }

    public init(
        value: String,
        placeholder: String? = nil,
        error: Binding<String?>? = nil,
        onContinue: @escaping (_ value: String) -> Void = { _ in }
    ) {
        self.placeholder = placeholder ?? ""
        self.value = value
        self._error = error ?? Binding.constant(nil)
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            hFieldLabel(
                placeholder: placeholder,
                animate: $animate,
                error: $error,
                shouldMoveLabel: shouldMoveLabel
            )
            .disabled(notSure)

            HStack(spacing: 16) {
                hText(displayLabel, style: .title3)
                    .foregroundColor(getLabelColor)
                Spacer()
                Toggle(isOn: $notSure.animation(.default)) {
                    HStack(spacing: 8) {
                        Spacer()
                        hText("I don't know", style: .body)
                            .foregroundColor(getToggleTextColor)
                    }
                }
                .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
                .contentShape(Rectangle())
            }
        }
        .padding(.top, 11)
        .padding(.bottom, 10)
        .addFieldBackground(animate: $animate, error: $error)
        .padding(.horizontal, 16)
        .onTapGesture {
            showPriceInputView()
        }
    }

    var displayLabel: String {
        if notSure {
            return "Unknown"
        } else {
            return value != "" ? value : "Enter here"
        }
    }

    @hColorBuilder
    var getLabelColor: some hColor {
        if notSure {
            hTextColor.tertiaryTranslucent
        } else if value != "" {
            hTextColor.primary
        } else {
            hTextColor.secondary
        }
    }

    @hColorBuilder
    var getToggleTextColor: some hColor {
        if notSure {
            hTextColor.primary
        } else {
            hTextColor.secondaryTranslucent
        }
    }

    private func showPriceInputView() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        let view = PriceInputScreen(
            continueAction: continueAction,
            cancelAction: cancelAction,
            onSave: { value in },
            purchasePrice: $value
        )

        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        )

        let priceInputJourney = journey.addConfiguration { presenter in
            continueAction.execute = {
                self.onContinue(value)
                presenter.dismisser(JourneyError.cancelled)
            }
            cancelAction.execute = {
                presenter.dismisser(JourneyError.cancelled)
            }
        }
        let vc = UIApplication.shared.getTopViewController()
        if let vc {
            disposeBag += vc.present(priceInputJourney)
        }
    }
}

struct PriceInputScreen: View {
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction

    @Binding fileprivate var purchasePrice: String
    @State var type: ClaimsFlowSingleItemFieldType? = .purchasePrice
    let currency: String
    var onSave: (String) -> Void

    init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        onSave: @escaping (String) -> Void,
        purchasePrice: Binding<String>
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self.onSave = onSave
        currency = "SEK" /* TODO: CHANGE */
        self._purchasePrice = purchasePrice
    }

    var body: some View {
        hForm {
            hSection {
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $purchasePrice,
                    equals: $type,
                    focusValue: .purchasePrice,
                    placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
                    suffix: currency
                )
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        UIApplication.dismissKeyboard()
                        onSave(purchasePrice)
                        continueAction.execute()
                    } content: {
                        hText(L10n.generalSaveButton, style: .body)
                    }
                    hButton.LargeButton(type: .ghost) {
                        cancelAction.execute()
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
        VStack(spacing: 5) {
            hOptOutField(value: "4500 SEK", placeholder: "Purchase price")
            hOptOutField(value: "", placeholder: "Purchase price")
            hOptOutField(value: "", placeholder: "Purchase price")
        }
    }
}

enum ClaimsFlowSingleItemFieldType: hTextFieldFocusStateCompliant {
    static var last: ClaimsFlowSingleItemFieldType {
        return ClaimsFlowSingleItemFieldType.purchasePrice
    }

    var next: ClaimsFlowSingleItemFieldType? {
        switch self {
        case .purchasePrice:
            return nil
        }
    }

    case purchasePrice
}
