import SwiftUI
import hCoreUI

struct SubmitClaimChatMesageView: View {
    let step: SubmitChatStepModel

    @ObservedObject var viewModel: SubmitClaimChatViewModel

    var body: some View {
        Group {
            switch step.step.content {
            case let .audioRecording(model):
                hText(model.hint)
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
            case .task(model: let model):
                hText("")
            case .summary(model: let model):
                hText("")
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
