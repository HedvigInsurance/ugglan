import SwiftUI
import TagKit
import hCoreUI

struct SubmitClaimFormView: View {
    @EnvironmentObject var mainVM: SubmitClaimChatViewModel
    @EnvironmentObject var viewModel: SubmitClaimFormStep

    var body: some View {
        VStack(spacing: .padding8) {
            VStack(alignment: .leading, spacing: .padding8) {
                ForEach(viewModel.formModel.fields, id: \.id) { field in
                    hText(field.title)
                    ZStack(alignment: .topLeading) {
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
                            FormBinaryView(vm: viewModel.getFormStepValue(for: field.id), options: field.options)
                        case .singleSelect:
                            singleSelectField(for: field)
                        }
                        if field.defaultValue != nil {
                            AiFillSparkles()
                                .offset(x: -9, y: -4)
                        }
                    }
                }
                .hWithoutHorizontalPadding([.section])
            }
            if viewModel.isEnabled {
                hButton(.medium, .primary, content: .init(title: "Send")) {
                    Task {
                        try await mainVM.submitStep(handler: viewModel)
                    }
                }
            }
        }
        .disabled(!viewModel.isEnabled)
        .detent(
            item: $viewModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
        }
        .detent(
            item: $viewModel.isSelectItemPresented,
            transitionType: .detent(style: [.height])
        ) { model in
            ItemPickerScreen<SingleSelectValue>(
                config: .init(
                    items: model.values.map({ ($0, .init(title: $0.title)) }),
                    preSelectedItems: {
                        let filedId = model.values[0].fieldId
                        let model = viewModel.getFormStepValue(for: filedId)
                        let options = viewModel.formModel.fields.first(where: { $0.id == filedId })?.options
                        let value = model.value

                        return options?.filter({ $0.value == value })
                            .map({ SingleSelectValue(fieldId: filedId, title: $0.title, value: $0.value) }) ?? []
                    },
                    onSelected: { value in
                        if let selectedValue = value.first, let fieldId = selectedValue.0?.fieldId,
                            let value = selectedValue.0?.value
                        {
                            viewModel.getFormStepValue(for: fieldId).value = value
                        }
                        viewModel.isSelectItemPresented = nil
                    }
                )
            )
            .hItemPickerAttributes([.singleSelect])
            .hFormContentPosition(.compact)
            .embededInNavigation(tracking: "")
            //            SubmitClaimSingleSelectScreen(viewModel: viewModel, values: model.values)
            //                .embededInNavigation(options: .largeNavigationBar, tracking: self)
        }
    }

    func dateField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        hSection {
            hRow {
                let date = viewModel.formValues[field.id]
                dropDownView(
                    message: date?.value ?? field.title,
                    fieldId: field.id
                )
            }
        }
        .onTapGesture {
            if viewModel.isEnabled {
                viewModel.dateForPicker = viewModel.formValues[field.id]?.value.localDateToDate ?? Date()
                viewModel.isDatePickerPresented = .init(
                    id: field.id,
                    continueAction: {
                        viewModel.formValues[viewModel.isDatePickerPresented?.id ?? ""] = .init(
                            value: viewModel.dateForPicker.localDateString
                        )
                        viewModel.isDatePickerPresented = nil
                    },
                    cancelAction: {
                        viewModel.isDatePickerPresented = nil
                    },
                    date: $viewModel.dateForPicker,
                    config: .init(placeholder: "placeholder", title: "Select date")
                )
            }
        }
    }

    func singleSelectField(for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) -> some View {
        let selectedValue = viewModel.getFormStepValue(for: field.id)
        let selectedOption = field.options.first(where: { $0.value == selectedValue.value })
        return DropdownView(
            value: selectedOption?.title ?? "",
            placeHolder: field.title
        ) {
            let values: [SingleSelectValue] = field.options.map {
                .init(fieldId: field.id, title: $0.title, value: $0.value)
            }
            viewModel.isSelectItemPresented = .init(id: field.id, values: values)
        }
        .disabled(!viewModel.isEnabled)
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
                            let enabled = currentBinaryValue.value == option.value
                            hButton(
                                .small,
                                enabled ? .primaryAlt : .secondary,
                                content: .init(title: option.title)
                            ) {
                                currentBinaryValue.value = option.value
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

    func dropDownView(message: String, fieldId: String) -> some View {
        HStack(alignment: .center, spacing: .padding4) {
            hText(message)
                .foregroundColor(dateColor(fieldId: fieldId))
            if viewModel.isEnabled {
                Spacer()
                hCoreUIAssets.chevronDown.view
            }
        }
    }

    @hColorBuilder
    func dateColor(fieldId: String) -> some hColor {
        let hasSelectedDate = viewModel.getFormStepValue(for: fieldId).value != ""
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
    let options: [ClaimIntentStepContentForm.ClaimIntentStepContentFormFieldOption]

    var body: some View {
        TagList(tags: options.compactMap({ $0.value })) { tag in
            hPill(text: options.first(where: { $0.value == tag })?.title ?? "", color: vm.value == tag ? .green : .grey)
                .onTapGesture {
                    withAnimation {
                        vm.value = tag
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

struct AiFillSparkles: View {
    @State private var isVisible = false
    var body: some View {
        Image(systemName: "sparkles")
            .foregroundColor(hSignalColor.Amber.element)
            .font(.system(size: 14))
            .padding(.padding4)
            .background(Circle().fill(hSignalColor.Amber.fill))
            .scaleEffect(isVisible ? 1.0 : 0.5)
            .opacity(isVisible ? 1.0 : 0.0)
            // Animate both scale and opacity
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isVisible)
            .onAppear {
                isVisible = true
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
