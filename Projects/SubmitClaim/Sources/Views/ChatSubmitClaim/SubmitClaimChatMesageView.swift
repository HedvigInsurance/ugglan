import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    let step: SubmitChatStepModel
    @ObservedObject var viewModel: SubmitClaimChatViewModel

    var body: some View {
        Group {
            mainContent()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, .padding12)
        .padding(.vertical, .padding8)
        .background(backgroundColor)
        .foregroundColor(hTextColor.Opaque.primary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
        .frame(
            maxWidth: maxWidth,
            alignment: alignment
        )
        .onTapGesture {
            onTap()
        }
        .environmentObject(viewModel)
    }

    func onTap() {
        switch step.step.content {
        case .form(model: let model):
            if step.isEnabled {
                switch model.fields.first?.type {
                case .date:
                    viewModel.isDatePickerPresented = .init(
                        continueAction: {
                            if let index = viewModel.dates.firstIndex(where: { $0.id == model.fields.first?.id ?? "" })
                            {
                                viewModel.dates.remove(at: index)
                            }
                            let newDate = (id: model.fields.first?.id ?? "", value: viewModel.selectedDate)
                            viewModel.dates.append(newDate)
                            viewModel.selectedDate = newDate.value
                            viewModel.isDatePickerPresented = nil
                        },
                        cancelAction: {
                            viewModel.isDatePickerPresented = nil
                        },
                        date: $viewModel.selectedDate,
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

    var maxWidth: CGFloat {
        if step.sender == .hedvig {
            switch step.step.content {
            case .outcome:
                return .infinity
            default:
                return 300
            }
        }
        return 300
    }

    var alignment: Alignment {
        if step.sender == .hedvig {
            switch step.step.content {
            case .outcome:
                return .center
            default:
                return .leading
            }
        }
        return .trailing
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
                SubmitClaimChatAudioRecorder(viewModel: viewModel, uploadURI: model.uploadURI)
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
                .fixedSize(horizontal: false, vertical: true)
        case .outcome(model: let model):
            VStack(spacing: .padding16) {
                hText(step.step.text)
                    .fixedSize(horizontal: false, vertical: true)
                hButton(.medium, .secondary, content: .init(title: "Go to claim")) {
                    viewModel.goToClaimDetails(model.claimId)
                }
            }
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

            if viewModel.hasClaimBeenSubmitted == nil {
                hButton(.medium, .primary, content: .init(title: "Submit your claim")) {
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
        } else {
            VStack(spacing: .padding8) {
                VStack(alignment: .center, spacing: .padding4) {
                    ForEach(model.fields, id: \.id) { field in
                        switch field.type {
                        case .date:
                            dateField(for: field)
                        case .number:
                            numberField(for: field)
                        case .singleSelect:
                            singleSelectField(for: field)
                        case .binary:
                            binaryField(for: field)
                        default:
                            EmptyView()
                        }
                    }
                    .hWithoutHorizontalPadding([.section])
                }
                if step.isEnabled {
                    hButton(.medium, .primary, content: .init(title: "Send")) {
                        Task {
                            await viewModel.submitForm(fields: model.fields)
                        }
                    }
                }
            }
        }
    }

    func dateField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        hSection {
            hRow {
                let date = viewModel.dates.first(where: { $0.id == field.id })?.value
                dropDownView(
                    message: date?.displayDateDDMMMYYYYFormat ?? field.title,
                    stepId: field.id
                )
            }
        }
        .onAppear {
            if let defaultValue = field.defaultValue {
                let date = (id: field.id, value: defaultValue.localDateToDate ?? Date())
                if viewModel.dates.first(where: { $0.id == field.id }) == nil {
                    viewModel.dates.append(date)
                    viewModel.selectedDate = date.value
                }
            }
        }
    }

    func singleSelectField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        let selectedValue = viewModel.selectedValue.first(where: { $0.fieldId == field.id })
        if let defaultValue = field.defaultValue {
            let defaultTitle = field.options.first(where: { $0.value == defaultValue })?.title ?? ""
            let value: SingleSelectValue = .init(fieldId: field.id, title: defaultTitle, value: defaultValue)
            if viewModel.selectedValue.first(where: { $0.fieldId == field.id }) == nil {
                viewModel.selectedValue.append(value)
            }
        }

        return DropdownView(
            value: selectedValue?.title ?? "",
            placeHolder: field.title
        ) {
            let values: [SingleSelectValue] = field.options.map {
                .init(fieldId: field.id, title: $0.title, value: $0.value)
            }
            viewModel.isSelectItemPresented = .init(id: field.id, values: values)
        }
        .disabled(!step.isEnabled)
    }

    func binaryField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        hSection {
            hRow {
                HStack(alignment: .center, spacing: .padding16) {
                    hText(field.title, style: .label)
                        .foregroundColor(binaryColor)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    ForEach(field.options, id: \.value) { option in
                        let currentBinaryValue = viewModel.binaryValues.first(where: {
                            $0.id == field.id
                        })

                        let enabled = currentBinaryValue?.value == option.value
                        hButton(
                            .small,
                            enabled ? .primaryAlt : .secondary,
                            content: .init(title: option.title)
                        ) {
                            if let i = viewModel.binaryValues.firstIndex(where: { $0.id == field.id }) {
                                viewModel.binaryValues[i].value = option.value
                            } else {
                                viewModel.binaryValues.append((id: field.id, value: option.value))
                            }
                        }
                        .disabled(!step.isEnabled)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            if let defaultValue = field.defaultValue {
                let value: (id: String, value: String) = (id: field.id, value: defaultValue)
                if viewModel.binaryValues.first(where: { $0.id == field.id }) == nil {
                    viewModel.binaryValues.append(value)
                }
            }
        }
    }

    func numberField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        hFloatingTextField(
            masking: .init(type: .digits),
            value: $viewModel.selectedPrice,
            equals: .constant(nil),
            focusValue: SubmitClaimChatFieldType.purchasePrice,
            placeholder: field.title,
            suffix: field.suffix
        )
        .disabled(!step.isEnabled)
        .onAppear {
            if let defaultValue = field.defaultValue {
                let value: (id: String, value: String) = (id: field.id, value: defaultValue)
                if viewModel.purchasePrice.first(where: { $0.id == field.id }) == nil {
                    viewModel.purchasePrice.append(value)
                    viewModel.selectedPrice = defaultValue
                }
            }
        }
    }

    func dropDownView(message: String, stepId: String) -> some View {
        HStack(alignment: .center, spacing: .padding4) {
            hText(message)
                .foregroundColor(dateColor(stepId: stepId))
            if step.isEnabled {
                Spacer()
                hCoreUIAssets.chevronDown.view
            }
        }
    }

    @hColorBuilder
    func dateColor(stepId: String) -> some hColor {
        let hasSelectedDate = viewModel.dates.first(where: { $0.id == stepId })?.value != nil
        if step.isEnabled && hasSelectedDate {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }

    @hColorBuilder
    var binaryColor: some hColor {
        if step.isEnabled {
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

    let viewModel = SubmitClaimChatViewModel(messageId: nil, goToClaimDetails: { _ in })

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
