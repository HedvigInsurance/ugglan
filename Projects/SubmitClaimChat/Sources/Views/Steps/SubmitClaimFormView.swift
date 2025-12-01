import SwiftUI
import TagKit
import hCore
import hCoreUI

struct SubmitClaimFormView: View {
    @ObservedObject var viewModel: SubmitClaimFormStep
    var body: some View {
        hSection {
            VStack(spacing: .padding8) {
                VStack(alignment: .leading, spacing: .padding8) {
                    ForEach(viewModel.formModel.fields, id: \.id) { field in
                        switch field.type {
                        case .date:
                            dateField(for: field)
                        case .number:
                            FormNumberView(
                                vm: viewModel.getFormStepValue(for: field.id),
                                title: field.title,
                                suffix: field.suffix
                            )
                        case .text:
                            FormTextView(
                                vm: viewModel.getFormStepValue(for: field.id),
                                title: field.title,
                                suffix: field.suffix
                            )
                        case .binary:
                            FormBinaryView(vm: viewModel.getFormStepValue(for: field.id), field: field)
                        case .singleSelect:
                            singleSelectField(for: field)
                        case .multiSelect:
                            multiSelectField(for: field)
                        }
                    }
                    .hWithoutHorizontalPadding([.section])
                }
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    Task {
                        await viewModel.submitResponse()
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .detent(
            item: $viewModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
        }
        .detent(
            item: $viewModel.isSelectItemPresented,
            transitionType: .detent(style: [.height])
        ) { [weak viewModel] model in
            ItemPickerScreen<SingleSelectValue>(
                config: .init(
                    items: model.values.map({ ($0, .init(title: $0.title)) }),
                    preSelectedItems: {
                        if let fieldModel = viewModel?.getFormStepValue(for: model.id),
                            let fieldOptions = viewModel?.formModel.fields.first(where: { $0.id == model.id })?.options
                        {
                            let selectedValues = fieldModel.values

                            return fieldOptions.filter({ selectedValues.contains($0.value) })
                                .map({ SingleSelectValue(title: $0.title, value: $0.value) })
                        }
                        return []
                    },
                    onSelected: { [weak viewModel] values in
                        viewModel?.getFormStepValue(for: model.id).values = values.compactMap({ $0.0?.value })
                        viewModel?.isSelectItemPresented = nil
                    }
                )
            )
            .hItemPickerAttributes(model.multiselect ? [] : [.singleSelect])
            .hFormContentPosition(.compact)
            .embededInNavigation(options: .largeNavigationBar, tracking: "")
        }
    }

    func dateField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        let selectedValue = viewModel.getFormStepValue(for: field.id)
        return DropdownView(
            value: selectedValue.value,
            placeHolder: field.title
        ) { [weak viewModel] in
            guard let viewModel else { return }
            if viewModel.isEnabled == true {
                viewModel.dateForPicker = viewModel.formValues[field.id]?.values.first?.localDateToDate ?? Date()
                viewModel.isDatePickerPresented = .init(
                    id: field.id,
                    continueAction: { [weak viewModel] in
                        guard let viewModel else { return }
                        viewModel.formValues[viewModel.isDatePickerPresented?.id ?? ""] = .init(
                            values: [viewModel.dateForPicker.localDateString]
                        )
                        viewModel.isDatePickerPresented = nil
                    },
                    cancelAction: { [weak viewModel] in
                        viewModel?.isDatePickerPresented = nil
                    },
                    date: $viewModel.dateForPicker,
                    config: .init(placeholder: "placeholder", title: "Select date")
                )
            }
        }
    }

    func singleSelectField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        let selectedValue = viewModel.getFormStepValue(for: field.id)
        let selectedOption = field.options.first(where: { selectedValue.values.contains($0.value) })
        return DropdownView(
            value: selectedOption?.title ?? "",
            placeHolder: field.title
        ) { [weak viewModel] in
            let values: [SingleSelectValue] = field.options.map {
                .init(title: $0.title, value: $0.value)
            }
            viewModel?.isSelectItemPresented = .init(id: field.id, values: values, multiselect: false)
        }
    }

    func multiSelectField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        let selectedValue = viewModel.getFormStepValue(for: field.id)
        let selectedOption = field.options.filter({ selectedValue.values.contains($0.value) })

        return DropdownView(
            value: selectedOption.map({ $0.title }).joined(separator: ", "),
            placeHolder: field.title
        ) { [weak viewModel] in
            let values: [SingleSelectValue] = field.options.map {
                .init(title: $0.title, value: $0.value)
            }
            viewModel?.isSelectItemPresented = .init(id: field.id, values: values, multiselect: true)
        }
    }

    func binaryField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        hSection {
            hRow {
                VStack(spacing: .padding8) {
                    hText(field.title, style: .label)
                        .foregroundColor(binaryColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        ForEach(field.options, id: \.value) { option in
                            let currentBinaryValue = viewModel.getFormStepValue(for: field.id)
                            let enabled = currentBinaryValue.values.first == option.value
                            hButton(
                                .small,
                                enabled ? .primaryAlt : .secondary,
                                content: .init(title: option.title)
                            ) {
                                currentBinaryValue.values = [option.value]
                            }
                            // .disabled makes the button styling disappear
                            // which means we don't see what we answered for old steps
                            .allowsHitTesting(viewModel.isEnabled)
                            .opacity(viewModel.isEnabled ? 1.0 : 0.6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    @hColorBuilder
    func dateColor(fieldId: String) -> some hColor {
        let hasSelectedDate = !viewModel.getFormStepValue(for: fieldId).values.isEmpty
        if viewModel.isEnabled && hasSelectedDate {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }

    @hColorBuilder
    var binaryColor: some hColor {
        if viewModel.isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }
}

struct FormNumberView: View {
    @ObservedObject var vm: FormStepValue
    let title: String
    let suffix: String?

    var body: some View {
        hFloatingTextField(
            masking: .init(type: .digits),
            value: $vm.value,
            equals: .constant(nil),
            focusValue: SubmitClaimChatFieldType.purchasePrice,
            placeholder: title,
            suffix: suffix
        )
    }
}

struct FormBinaryView: View {
    @ObservedObject var vm: FormStepValue
    let field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(field.title)
            TagList(tags: field.options.compactMap({ $0.value })) { tag in
                hPill(
                    text: field.options.first(where: { $0.value == tag })?.title ?? "",
                    color: vm.value == tag ? .green : .grey
                )
                .onTapGesture {
                    withAnimation { [weak vm] in
                        vm?.value = tag
                    }
                }
            }
        }
    }
}

struct FormTextView: View {
    @ObservedObject var vm: FormStepValue
    let title: String
    let suffix: String?

    var body: some View {
        hFloatingTextField(
            masking: .init(type: .none),
            value: $vm.value,
            equals: .constant(nil),
            focusValue: SubmitClaimChatFieldType.purchasePrice,
            placeholder: title,
            suffix: suffix
        )
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

struct SubmitClaimFormResultView: View {
    @ObservedObject var viewModel: SubmitClaimFormStep
    var body: some View {
        if viewModel.isStepExecuted {
            VStack(alignment: .trailing, spacing: .padding4) {
                ForEach(viewModel.getAllValuesToShow(), id: \.0) { item in
                    VStack(alignment: .trailing, spacing: 0) {
                        hText(item.0, style: .label)
                        hPill(text: item.1, color: .grey)
                    }
                }
            }
        }
    }
}

#Preview {
    SubmitClaimFormView(
        viewModel: ClaimIntentClientDemo().demoFormModel
    )
}
