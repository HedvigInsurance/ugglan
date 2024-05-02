import SwiftUI
import hCore
import hCoreUI

struct SurveyScreen: View {
    @StateObject var vm = SurveyScreenViewModel()
    var body: some View {
        hForm {

        }
        .hFormTitle(
            title: .init(
                .small,
                .title3,
                L10n.terminationFlowCancellationTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .small,
                .title3,
                "What is the reason for cancelling?"
            )
        )
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        ForEach(vm.options) { option in
                            VStack(spacing: 4) {
                                hRadioField(
                                    id: option.id,
                                    content: {
                                        hText(option.title)
                                    },
                                    selected: $vm.selected
                                )

                                if let feedBack = option.feedBack, option.id == vm.selectedOption?.id {
                                    CustomTextViewRepresentable(
                                        placeholder: L10n.claimsTextInputPlaceholder,
                                        text: $vm.text
                                    )
                                    .cornerRadius(12)
                                    .frame(height: 128)
                                }
                                if let suggestion = option.suggestion, option.id == vm.selectedOption?.id {
                                    buildInfo(for: suggestion)
                                }
                            }
                        }
                    }
                    hButton.LargeButton(type: .primary) {

                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                }

            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    func buildInfo(for suggestion: TerminationFlowSurveyStepSuggestion) -> some View {
        switch suggestion {
        case .action(let action):
            InfoCard(text: "action", type: .info)
                .buttons([
                    .init(
                        buttonTitle: L10n.dashboardRenewalPrompterBodyButton,
                        buttonAction: {

                        }
                    )
                ])
        case .redirect(let redirect):
            InfoCard(text: redirect.description, type: .info)
                .buttons([
                    .init(
                        buttonTitle: redirect.buttonTitle,
                        buttonAction: {

                        }
                    )
                ])
        }
    }
}

class SurveyScreenViewModel: ObservableObject {
    @Published var text: String = "test"
    @Published var continueEnabled = true
    @Published var selected: String? {
        didSet {
            withAnimation {
                selectedOption = options.first(where: { $0.id == selected })
            }
        }
    }

    init() {

    }

    @Published var selectedOption: TerminationFlowSurveyStepModelOption?
    let options: [TerminationFlowSurveyStepModelOption] = [
        .init(
            id: "optionId",
            title: "Option title",
            suggestion: .action(
                action: .init(
                    id: "actionId",
                    action: .updateAddress
                )
            ),
            feedBack: .init(
                id: "feedbackId",
                isRequired: true
            ),
            subOptions: nil
        ),
        .init(
            id: "optionId2",
            title: "Option title 2",
            suggestion: .action(
                action: .init(
                    id: "actionId",
                    action: .messageUs
                )
            ),
            feedBack: .init(
                id: "feedbackId",
                isRequired: true
            ),
            subOptions: nil
        ),
    ]
}

#Preview{
    SurveyScreen()
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    public func makeUIView(context: Context) -> some UIView {
        CustomTextView(placeholder: placeholder, inputText: $text)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

private class CustomTextView: UITextView, UITextViewDelegate {
    let placeholder: String
    @Binding var inputText: String

    init(placeholder: String, inputText: Binding<String>) {
        self.placeholder = placeholder
        self._inputText = inputText
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 4, verticalInset: 4)
        self.delegate = self
        self.font = Fonts.fontFor(style: .standard)
        if inputText.wrappedValue.isEmpty {
            self.text = placeholder
            self.textColor = UIColor.lightGray
        } else {
            self.text = inputText.wrappedValue
            self.textColor = UIColor.black
        }
        self.backgroundColor = UIColor(hFillColor.opaqueOne.colorFor(.light, .base).color)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonTap)
        )
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)

        self.inputAccessoryView = toolbar
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = text
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}
