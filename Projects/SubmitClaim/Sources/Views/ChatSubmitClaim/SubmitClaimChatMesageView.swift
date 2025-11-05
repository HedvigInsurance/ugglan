import SwiftUI
import hCore
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
            case .form(model: let model):
                if !viewModel.hasEnteredFormInput {
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
                }
            default:
                break
            }
        }
        .environmentObject(viewModel)
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
            FormView(step: step, model: model)
        case let .task(model):
            VStack(alignment: .leading) {
                hText(step.step.text)
                hText(model.description, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        case .summary(model: let model):
            summaryView(model: model)
        case .text:
            hText(step.step.text)
        }
    }

    func summaryView(model: ClaimIntentStepContentSummary) -> some View {
        VStack(spacing: .padding8) {
            VStack(alignment: .leading) {
                hText(step.step.text)
                hRowDivider()
                    .hWithoutHorizontalPadding([.divider])
            }

            VStack(alignment: .leading, spacing: .padding4) {
                ForEach(model.audioRecordings, id: \.url) { url in
                    hSection {
                        SubmitClaimChatAudioRecorder(viewModel: viewModel, uploadURI: "")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .hWithoutHorizontalPadding([.section])
                }

                ForEach(model.items, id: \.title) { item in
                    HStack {
                        hText(item.title, style: .label)
                        Spacer()
                        hText(item.value, style: .label)
                    }
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.hasSubmittedClaim {
                hButton(.medium, .primary, content: .init(title: "Yes, submit claim")) {
                    Task {
                        await viewModel.submitSummary()
                    }
                }
            }
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

struct FormView: View {
    let step: SubmitChatStepModel
    let model: ClaimIntentStepContentForm
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel

    var body: some View {
        if step.sender == .hedvig {
            hText(step.step.text)
                .fixedSize()
        } else {
            VStack(spacing: .padding8) {
                VStack(alignment: .center, spacing: .padding4) {
                    ForEach(model.fields, id: \.id) { field in
                        switch field.type {
                        case .date:
                            hSection {
                                hRow {
                                    dropDownView(
                                        message: viewModel.hasSelectedDate
                                            ? viewModel.date.displayDateDDMMMYYYYFormat
                                            : field.title
                                    )
                                }
                            }

                        case .number:
                            hFloatingTextField(
                                masking: .init(type: .digits),
                                value: $viewModel.purchasePrice,
                                equals: .constant(nil),
                                focusValue: SubmitClaimChatFieldType.purchasePrice,
                                placeholder: field.title,
                                suffix: field.suffix
                            )
                            .disabled(viewModel.hasEnteredFormInput)

                        case .singleSelect:
                            DropdownView(
                                value: viewModel.selectedValue.title,
                                placeHolder: field.title
                            ) {
                                let values: [SingleSelectValue] = field.options.map {
                                    .init(title: $0.title, value: $0.value)
                                }
                                viewModel.isSelectItemPresented = .init(values: values)
                            }
                            .disabled(viewModel.hasEnteredFormInput)
                        case .binary:
                            hSection {
                                hRow {
                                    HStack(alignment: .center, spacing: .padding16) {
                                        hText(field.title, style: .label)
                                            .foregroundColor(binaryColor)
                                            .fixedSize(horizontal: true, vertical: false)
                                        Spacer()
                                        ForEach(field.options, id: \.value) { option in
                                            let enabled = viewModel.binaryValue == option.value
                                            hButton(
                                                .small,
                                                enabled ? .primaryAlt : .secondary,
                                                content: .init(title: option.title)
                                            ) { viewModel.binaryValue = option.value }
                                            .disabled(viewModel.hasEnteredFormInput)
                                        }
                                        .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }

                        default:
                            EmptyView()
                        }
                    }
                    .hWithoutHorizontalPadding([.section])
                }
                if !viewModel.hasEnteredFormInput {
                    hButton(.medium, .primary, content: .init(title: "Send")) {
                        Task {
                            await viewModel.submitForm(fields: model.fields)
                        }
                    }
                }
            }
        }
    }

    func dropDownView(message: String) -> some View {
        HStack(alignment: .center, spacing: .padding4) {
            hText(message)
                .foregroundColor(dateColor)
            if !viewModel.hasEnteredFormInput {
                Spacer()
                hCoreUIAssets.chevronDown.view
            }
        }
    }

    @hColorBuilder
    var dateColor: some hColor {
        if viewModel.hasSelectedDate && !viewModel.hasEnteredFormInput {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }

    @hColorBuilder
    var binaryColor: some hColor {
        if !viewModel.hasEnteredFormInput {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
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

#Preview {
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })

    let viewModel = SubmitClaimChatViewModel()
    viewModel.date = Date()

    return SubmitClaimChatMesageView(
        step:
            .init(
                step: .init(
                    content: .form(
                        model: .init(fields: [
                            .init(
                                defaultValue: nil,
                                id: "",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [],
                                suffix: nil,
                                title: "",
                                type: .date
                            )
                        ])
                    ),
                    id: "id1",
                    text: "Select a date"
                ),
                sender: .member,
                isLoading: false
            ),
        viewModel: viewModel
    )
}
