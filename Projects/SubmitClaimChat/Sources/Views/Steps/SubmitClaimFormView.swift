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
                        FormFieldView(
                            viewModel: viewModel,
                            fieldViewModel: viewModel.getFormStepValue(for: field.id),
                            field: field
                        )
                    }
                    .hWithoutHorizontalPadding([.section])
                }
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    viewModel.submitResponse()
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .detent(
            item: $viewModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
                .embededInNavigation(options: .largeNavigationBar, tracking: self)
        }
        .detent(
            item: $viewModel.isSelectItemPresented,
            transitionType: .detent(style: [.height])
        ) { [weak viewModel] model in
            let title = viewModel?.claimIntent.currentStep.text ?? ""
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
            .navigationTitle(title)
            .embededInNavigation(options: .largeNavigationBar, tracking: self)
        }
    }
}

extension SubmitClaimFormView: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: SubmitClaimFormView.self)
    }
}

struct FormFieldView: View {
    @ObservedObject var viewModel: SubmitClaimFormStep
    @ObservedObject var fieldViewModel: FormStepValue
    let field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField

    var body: some View {
        switch field.type {
        case .date:
            dateField
        case .number:
            numberView
        case .text:
            textView
        case .binary:
            binaryField
        case .singleSelect:
            singleSelectField
        case .multiSelect:
            multiSelectField
        }
    }

    var numberView: some View {
        hFloatingTextField(
            masking: .init(type: .digits),
            value: $fieldViewModel.value,
            equals: .constant(nil),
            focusValue: SubmitClaimChatFieldType.purchasePrice,
            placeholder: field.title,
            suffix: field.suffix,
            error: $fieldViewModel.error
        )
    }

    var textView: some View {
        hFloatingTextField(
            masking: .init(type: .none),
            value: $fieldViewModel.value,
            equals: .constant(nil),
            focusValue: SubmitClaimChatFieldType.purchasePrice,
            placeholder: field.title,
            suffix: field.suffix,
            error: $fieldViewModel.error
        )
    }

    private var dateField: some View {
        DropdownView(
            value: fieldViewModel.value,
            placeHolder: field.title,
            error: $fieldViewModel.error
        ) { [weak viewModel] in
            guard let viewModel else { return }
            if viewModel.isEnabled == true {
                viewModel.dateForPicker = fieldViewModel.values.first?.localDateToDate ?? Date()
                viewModel.isDatePickerPresented = .init(
                    id: field.id,
                    continueAction: { [weak viewModel] in
                        guard let viewModel else { return }
                        fieldViewModel.value = viewModel.dateForPicker.localDateString
                        viewModel.isDatePickerPresented = nil
                    },
                    cancelAction: { [weak viewModel] in
                        viewModel?.isDatePickerPresented = nil
                    },
                    date: $viewModel.dateForPicker,
                    config: .init(
                        minDate: field.minValue?.localDateToDate,
                        maxDate: field.maxValue?.localDateToDate,
                        placeholder: "placeholder",
                        title: "Select date",
                    )
                )
            }
        }
    }

    private var singleSelectField: some View {
        let selectedValue = viewModel.getFormStepValue(for: field.id)
        let selectedOption = field.options.first(where: { selectedValue.values.contains($0.value) })
        return DropdownView(
            value: selectedOption?.title ?? "",
            placeHolder: field.title,
            error: $fieldViewModel.error
        ) { [weak viewModel] in
            let values: [SingleSelectValue] = field.options.map {
                .init(title: $0.title, value: $0.value)
            }
            viewModel?.isSelectItemPresented = .init(id: field.id, values: values, multiselect: false)
        }
    }

    private var multiSelectField: some View {
        let selectedValue = viewModel.getFormStepValue(for: field.id)
        let selectedOption = field.options.filter({ selectedValue.values.contains($0.value) })

        return DropdownView(
            value: selectedOption.map({ $0.title }).joined(separator: ", "),
            placeHolder: field.title,
            error: $fieldViewModel.error
        ) { [weak viewModel] in
            let values: [SingleSelectValue] = field.options.map {
                .init(title: $0.title, value: $0.value)
            }
            viewModel?.isSelectItemPresented = .init(id: field.id, values: values, multiselect: true)
        }
    }

    private var binaryField: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(field.title)
            TagList(tags: field.options.compactMap({ $0.value })) { tag in
                hPill(
                    text: field.options.first(where: { $0.value == tag })?.title ?? "",
                    color: fieldViewModel.value == tag ? .green : .grey
                )
                .onTapGesture {
                    withAnimation { [weak fieldViewModel] in
                        fieldViewModel?.value = tag
                    }
                }
            }
            if let error = fieldViewModel.error {
                HStack {
                    hText(error, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                .padding(.leading, .padding16)
            }
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

struct SubmitClaimFormResultView: View {
    @ObservedObject var viewModel: SubmitClaimFormStep
    var body: some View {
        if viewModel.isStepExecuted {
            VStack(alignment: .trailing, spacing: .padding4) {
                ForEach(viewModel.getAllValuesToShow(), id: \.0) { item in
                    HStack(alignment: .center, spacing: .padding8) {
                        hText(item.0, style: .label)
                            .foregroundColor(hTextColor.Opaque.accordion)
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
