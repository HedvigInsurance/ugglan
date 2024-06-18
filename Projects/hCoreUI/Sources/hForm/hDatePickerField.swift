import Flow
import SwiftUI
import hCore

public class hDatePickerFieldNavigationModel: ObservableObject {
    @Published var isDatePickerPresented: DatePickerViewModel?
}

public struct hDatePickerField: View {
    private let config: HDatePickerFieldConfig
    private let onUpdate: (_ date: Date) -> Void
    private let onContinue: (_ date: Date) -> Void
    private let onShowDatePicker: (() -> Void)?

    @State private var animate = false

    @State private var date: Date = Date()
    private var selectedDate: Date?

    @Binding var error: String?
    @State private var disposeBag = DisposeBag()
    private var placeholderText: String?
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hFieldSize) var size

    @StateObject var datePickerNavigationModel = hDatePickerFieldNavigationModel()
    @EnvironmentObject var router: Router

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { !(selectedDate?.localDateString.isEmpty ?? true) },
            set: { _ in }
        )
    }

    public init(
        config: HDatePickerFieldConfig,
        selectedDate: Date?,
        placehodlerText: String? = "",
        error: Binding<String?>? = nil,
        onContinue: @escaping (_ date: Date) -> Void = { _ in },
        onShowDatePicker: (() -> Void)? = nil
    ) {
        self.config = config
        self.onUpdate = { _ in }
        self.onContinue = onContinue
        self.onShowDatePicker = onShowDatePicker
        self.selectedDate = selectedDate
        self._error = error ?? Binding.constant(nil)
        self.date = selectedDate ?? config.minDate ?? Date()
        self.placeholderText = placehodlerText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                hFieldLabel(
                    placeholder: config.placeholder,
                    animate: $animate,
                    error: $error,
                    shouldMoveLabel: shouldMoveLabel
                )
                .offset(y: !(selectedDate?.localDateString.isEmpty ?? true) ? size.labelOffset : 0)
                getValueLabel()
            }
            .padding(.top, size.topPaddingNewDesign)
            .padding(.bottom, size.bottomPaddingNewDesign)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: selectedDate) { date in
                if let date {
                    error = nil
                    onUpdate(date)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            self.date = selectedDate ?? config.minDate ?? Date()
            if let onShowDatePicker {
                onShowDatePicker()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showDatePicker()
                }
            } else {
                showDatePicker()
            }
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
        .disabled(!isEnabled)
        .detent(
            item: $datePickerNavigationModel.isDatePickerPresented,
            style: .height
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
                .embededInNavigation(options: .largeNavigationBar)
        }
    }

    private func getValueLabel() -> some View {
        HStack {
            Group {
                if config.dateFormatter == .DDMMMYYYY {
                    if (selectedDate?.displayDateDDMMMYYYYFormat) != nil {
                        Text((selectedDate?.displayDateDDMMMYYYYFormat ?? placeholderText) ?? L10n.generalSelectButton)
                    }
                } else if config.dateFormatter == .birthDate {
                    if (selectedDate?.localBirthDateString) != nil {
                        Text((selectedDate?.localBirthDateString ?? placeholderText) ?? L10n.generalSelectButton)
                    }
                }
            }
            .modifier(hFontModifier(style: size == .large ? .body2 : .body1))
            .foregroundColor(foregroundColor)
            Spacer()
        }
        .offset(y: !(selectedDate?.localDateString.isEmpty ?? true) ? size.fieldOffset : 0)

    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }

    private func showDatePicker() {
        let continueAction = ReferenceAction {}
        if let initialySelectedValue = config.initialySelectedValue, selectedDate == nil {
            date = initialySelectedValue
        }

        datePickerNavigationModel.isDatePickerPresented = .init(
            continueAction: continueAction,
            cancelAction: {
                router.dismiss()
            },
            date: $date,
            config: config
        )

        continueAction.execute = {
            self.onContinue(date)
            router.dismiss()
        }
    }

    public struct HDatePickerFieldConfig {
        let minDate: Date?
        let maxDate: Date?
        let initialySelectedValue: Date?
        let placeholder: String
        let title: String
        let showAsList: Bool?
        let dateFormatter: DateFormatter?
        let buttonText: String?

        public init(
            minDate: Date? = nil,
            maxDate: Date? = nil,
            initialySelectedValue: Date? = nil,
            placeholder: String,
            title: String,
            showAsList: Bool? = false,
            dateFormatter: DateFormatter? = .DDMMMYYYY,
            buttonText: String? = nil
        ) {
            self.minDate = minDate
            self.maxDate = maxDate
            self.initialySelectedValue = initialySelectedValue
            self.placeholder = placeholder
            self.title = title
            self.showAsList = showAsList
            self.dateFormatter = dateFormatter
            self.buttonText = buttonText
        }
    }
}

public class DatePickerViewModel: ObservableObject, Equatable, Identifiable {
    public static func == (lhs: DatePickerViewModel, rhs: DatePickerViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    public var id: String?
    let continueAction: ReferenceAction
    let cancelAction: ReferenceAction
    @Binding var date: Date
    @Published var dateSelected: Date {
        didSet {
            date = dateSelected
        }
    }
    let config: hDatePickerField.HDatePickerFieldConfig

    init(
        continueAction: ReferenceAction,
        cancelAction: @escaping () -> Void,
        date: Binding<Date>,
        config: hDatePickerField.HDatePickerFieldConfig
    ) {
        self.continueAction = continueAction

        self.cancelAction = .init(execute: {
            cancelAction()
        })

        self.dateSelected = date.wrappedValue
        self._date = date
        self.config = config
    }

    public init(
        continueAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void,
        date: Binding<Date>,
        config: hDatePickerField.HDatePickerFieldConfig
    ) {
        self.continueAction = .init(execute: {
            continueAction()
        })
        self.cancelAction = .init(execute: {
            cancelAction()
        })
        self._date = date
        self.dateSelected = date.wrappedValue
        self.config = config
    }
}

public struct DatePickerView: View {
    @ObservedObject var vm: DatePickerViewModel

    public init(
        vm: DatePickerViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        hForm {
            hSection {
                HStack {
                    if vm.config.showAsList ?? false {
                        datePicker
                            .datePickerStyle(.wheel)
                            .padding(.trailing, 23)
                            .padding(.bottom, .padding16)
                    } else {
                        datePicker
                            .datePickerStyle(.graphical)
                            .frame(height: 340)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hDisableScroll
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButton(type: .primary) {
                    vm.continueAction.execute()
                } content: {
                    hText(
                        vm.config.buttonText ?? L10n.generalSaveButton,
                        style: .body1
                    )
                    .foregroundColor(hTextColor.Opaque.negative)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding(.horizontal, .padding16)

                hButton.LargeButton(type: .ghost) {
                    vm.cancelAction.execute()
                } content: {
                    hText(
                        L10n.generalCancelButton,
                        style: .body1
                    )
                    .foregroundColor(hTextColor.Opaque.primary)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    hText(vm.config.title)
                    if let subtitle = vm.dateSelected.displayDateDDMMMYYYYFormat, !(vm.config.showAsList ?? false) {
                        hText(subtitle).foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
            }
        }
    }

    private var datePicker: some View {
        let minDate = vm.config.minDate
        let maxDate = vm.config.maxDate
        if let minDate, let maxDate {
            return DatePicker(
                "",
                selection: $vm.dateSelected.animation(.easeInOut(duration: 0.2)),
                in: minDate...maxDate,
                displayedComponents: [.date]
            )
        } else if let minDate {
            return DatePicker(
                "",
                selection: $vm.dateSelected.animation(.easeInOut(duration: 0.2)),
                in: minDate...,
                displayedComponents: [.date]
            )
        } else if let maxDate {
            return DatePicker(
                "",
                selection: $vm.dateSelected.animation(.easeInOut(duration: 0.2)),
                in: ...maxDate,
                displayedComponents: [.date]
            )
        } else {
            return DatePicker(
                "",
                selection: $vm.dateSelected,
                displayedComponents: [.date]
            )
        }
    }
}

struct hDatePickerField_Previews: PreviewProvider {
    @State private static var dateForSmall: Date?
    @State private static var dateForSmallWithRealDate: Date? = Date()
    @State private static var dateForLarge: Date?
    @State private static var dateForLargeWithRealDate: Date? = Date()

    private static let config =
        hDatePickerField
        .HDatePickerFieldConfig(
            placeholder: "Placeholder",
            title: "Departure date"
        )
    static var previews: some View {
        VStack {
            hDatePickerField(config: config, selectedDate: dateForSmall)
                .hFieldSize(.small)
            hDatePickerField(config: config, selectedDate: dateForSmallWithRealDate)
                .hFieldSize(.small)
            hDatePickerField(config: config, selectedDate: dateForLarge)
            hDatePickerField(config: config, selectedDate: dateForLargeWithRealDate)
        }
    }
}

class ReferenceAction {
    var execute: () -> (Void)

    init(
        execute: @escaping () -> Void
    ) {
        self.execute = execute
    }
}

public enum DateFormatter {
    case DDMMMYYYY
    case birthDate
}
