import SwiftUI
import hCoreUI

struct SubmitClaimChatMesageView: View {
    let step: SubmitChatStepModel
    @ObservedObject var viewModel: SubmitClaimChatViewModel

    var body: some View {
        Group {
            switch step.step.content {
            case let .audioRecording(model):
                if step.sender == .hedvig {
                    hText(model.hint)
                } else {
                    switch step.step.content {
                    case let .audioRecording(model):
                        SubmitClaimChatAudioRecorder(viewModel: viewModel, uploadURI: model.uploadURI)
                    default:
                        EmptyView()
                    }
                }
            case .form(model: let model):
                hText("")
                switch model.fields.first?.type {
                case .date:
                    dropDownView(
                        message: viewModel.hasSelectedDate ? viewModel.date.displayDateDDMMMYYYYFormat : "Selected date"
                    )
                default:
                    EmptyView()
                }
            case let .task(model):
                VStack(alignment: .leading) {
                    hText(step.step.text)
                    if !model.isCompleted {
                        hText(model.description)
                    }
                }
            case .summary(model: let model):
                VStack(spacing: .padding16) {
                    VStack(alignment: .leading, spacing: .padding4) {
                        VStack(alignment: .leading) {
                            hText("Summary of your claim")
                            hRowDivider()
                                .hWithoutHorizontalPadding([.divider])
                        }
                        hText("audio recording text", style: .label)
                            .foregroundColor(hTextColor.Opaque.secondary)

                        ForEach(model.items, id: \.title) { item in
                            HStack {
                                hText(item.title, style: .label)
                                Spacer()
                                hText(item.value, style: .label)
                            }
                            .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }

                    hButton(.medium, .primary, content: .init(title: "Submit claim")) {
                        // TODO: close and show dubmit claim
                    }
                }
            case .text:
                hText(step.step.text)
            }
        }
        .padding(.horizontal, .padding12)
        .padding(.vertical, .padding8)
        .background(backgroundColor)
        .foregroundColor(hTextColor.Opaque.primary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
        .frame(
            maxWidth: 300,
            alignment: step.sender == .hedvig ? .leading : .trailing
        )
        .onTapGesture {
            switch step.step.content {
            case .audioRecording:
                print("Tapped audio")
            case .form(model: let model):
                switch model.fields.first?.type {
                case .date:
                    viewModel.isDatePickerPresented = .init(
                        continueAction: {
                            viewModel.hasSelectedDate = true
                            viewModel.isDatePickerPresented = nil
                        },
                        cancelAction: {
                            viewModel.isDatePickerPresented = nil
                        },
                        date: $viewModel.date,
                        config: .init(placeholder: "placeholder", title: "Select date")
                    )
                default:
                    break
                }
            case .task(model: let model):
                break
            case .summary(model: let model):
                break
            case .text:
                break
            }
        }
    }

    func dropDownView(message: String) -> some View {
        HStack(spacing: .padding4) {
            hText(message)
            hCoreUIAssets.chevronDown.view
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch step.sender {
        case .member:
            hSurfaceColor.Translucent.primary
        case .hedvig:
            hBackgroundColor.clear
        }
    }
}
