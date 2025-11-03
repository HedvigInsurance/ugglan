import SwiftUI
import hCoreUI

struct SubmitClaimChatMesageView: View {
    let step: SubmitChatStepModel
    @ObservedObject var viewModel: SubmitClaimChatViewModel

    var body: some View {
        Group {
            mainContent()
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

    @ViewBuilder
    func mainContent() -> some View {
        switch step.step.content {
        case let .audioRecording(model):
            if step.sender == .hedvig {
                VStack(alignment: .leading) {
                    hText(step.step.text)
                    hText(model.hint)
                }
            } else {
                switch step.step.content {
                case let .audioRecording(model):
                    SubmitClaimChatAudioRecorder(viewModel: viewModel, uploadURI: model.uploadURI)
                default:
                    EmptyView()
                }
            }
        case .form(model: let model):

            if step.sender == .hedvig {
                hText(step.step.text)
            } else {
                VStack(alignment: .trailing) {
                    ForEach(model.fields, id: \.id) { field in
                        switch field.type {
                        case .date:
                            hSection {
                                hRow {
                                    dropDownView(
                                        message: viewModel.hasSelectedDate
                                            ? viewModel.date.displayDateDDMMMYYYYFormat : field.title
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .frame(maxWidth: 250)
                            .hWithoutHorizontalPadding([.section])
                        case .number:
                            hFloatingTextField(
                                masking: .init(type: .digits),
                                value: $viewModel.purchasePrice,
                                equals: .constant(nil),
                                focusValue: SubmitClaimChatFieldType.purchasePrice,
                                placeholder: field.title,
                                suffix: field.suffix
                            )
                            .frame(maxWidth: 250)
                        case .singleSelect:
                            EmptyView()
                        // todo: implement
                        default:
                            EmptyView()
                        }
                    }
                    hButton(.small, .primary, content: .init(title: "Send")) {
                        Task {
                            await viewModel.submitForm(fields: model.fields)
                        }
                    }
                }
                .frame(width: 300)
            }

        case let .task(model):
            VStack(alignment: .leading) {
                hText(step.step.text)
                hText(model.description)
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
            switch step.step.content {
            case .form:
                hBackgroundColor.clear
            default:
                hSurfaceColor.Translucent.primary
            }

        case .hedvig:
            hBackgroundColor.clear
        }
    }
}

enum SubmitClaimChatFieldType: hTextFieldFocusStateCompliant {
    static var last: SubmitClaimChatFieldType {
        SubmitClaimChatFieldType.purchasePrice
    }

    var next: SubmitClaimChatFieldType? {
        switch self {
        case .purchasePrice:
            return nil
        }
    }

    case purchasePrice
}
