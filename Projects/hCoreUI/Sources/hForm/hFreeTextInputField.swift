import Flow
import Presentation
import SwiftUI
import hCore

public struct hFreeTextInputField: View {
    private var placeholder: String
    @State private var animate = false
    private var selectedValue: String?
    @Binding var error: String?
    @State private var value: String
    @State private var disposeBag = DisposeBag()
    private let onContinue: (_ date: String) -> Void
    private let infoCardText: String?

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
        onContinue: @escaping (_ date: String) -> Void = { _ in },
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
    }

    private func showFreeTextField() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        value = selectedValue ?? ""

        let view = freeTextInputView(
            continueAction: continueAction,
            cancelAction: cancelAction,
            value: $value,
            infoCardText: infoCardText
        )

        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        )
        .configureTitle(placeholder)

        let freeTextFieldJourney = journey.addConfiguration { presenter in
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
            disposeBag += vc.present(freeTextFieldJourney)
        }
    }

    private struct freeTextInputView: View {
        fileprivate let continueAction: ReferenceAction
        fileprivate let cancelAction: ReferenceAction
        @Binding fileprivate var value: String
        private let maxCharacters = 140
        private let infoCardText: String?

        public init(
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

        public var body: some View {
            hForm {
                VStack(spacing: 16) {
                    VStack {
                        hTextField(
                            masking: Masking(type: .none),
                            value: $value,
                            placeholder: L10n.textInputFieldPlaceholder
                        )
                        .hTextFieldOptions([.useLineBreak, .minimumHeight(height: 96)])
                        Spacer()
                        hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                            .foregroundColor(getTextColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding([.horizontal, .top], 16)
                    .padding(.bottom, 12)
                    .background(
                        Squircle.default()
                            .fill(hFillColor.opaqueOne)
                    )
                    if let infoCardText {
                        InfoCard(text: infoCardText, type: .info)
                    }
                }
                .padding(.horizontal, 16)
            }
            .hFormAttachToBottom {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        continueAction.execute()
                    } content: {
                        hText(L10n.generalSaveButton)
                    }
                    .disabled(value.count > maxCharacters)
                    hButton.LargeButton(type: .ghost) {
                        cancelAction.execute()
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
            if value.count < maxCharacters {
                hTextColor.tertiary
            } else {
                hSignalColor.redElement
            }
        }
    }
}

#Preview{
    VStack(spacing: 4) {
        hFreeTextInputField(selectedValue: "", placeholder: "Type of damage")
        hFreeTextInputField(selectedValue: "value", placeholder: "placeholder")
    }
}
