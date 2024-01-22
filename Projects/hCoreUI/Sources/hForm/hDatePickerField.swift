import Flow
import Presentation
import SwiftUI
import hCore

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
            VStack(alignment: .leading, spacing: 0) {
                hFieldLabel(
                    placeholder: config.placeholder,
                    animate: $animate,
                    error: $error,
                    shouldMoveLabel: shouldMoveLabel
                )
                getValueLabel()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(
                .vertical,
                selectedDate?.localDateString.isEmpty ?? true ? (size == .large ? 0 : 3) : (size == .large ? 10 : 7.5)
            )
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
    }

    private func getValueLabel() -> some View {
        HStack {
            Group {
                if config.dateFormatter == .DDMMMYYYY {
                    if (selectedDate?.displayDateDDMMMYYYYFormat) != nil {
                        Text((selectedDate?.displayDateDotFormat ?? placeholderText) ?? L10n.generalSelectButton)
                    }
                } else if config.dateFormatter == .birthDate {
                    if (selectedDate?.displayDateYYMMDDFormat) != nil {
                        Text((selectedDate?.displayDateYYMMDDFormat ?? placeholderText) ?? L10n.generalSelectButton)
                    }
                }
            }
            .modifier(hFontModifier(style: size == .large ? .title3 : .standard))
            .foregroundColor(hTextColor.primary)
            Spacer()
        }
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColor.primary
        } else {
            hTextColor.secondary
        }
    }

    private func showDatePicker() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}
        if let initialySelectedValue = config.initialySelectedValue, selectedDate == nil {
            date = initialySelectedValue
        }
        let view = DatePickerView(
            continueAction: continueAction,
            cancelAction: cancelAction,
            date: $date,
            config: config
        )
        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        )

        let calendarJourney = journey.addConfiguration { presenter in
            continueAction.execute = {
                self.onContinue(date)
                presenter.dismisser(JourneyError.cancelled)
            }
            cancelAction.execute = {
                presenter.dismisser(JourneyError.cancelled)
            }
        }
        let vc = UIApplication.shared.getTopViewController()
        if let vc {
            disposeBag += vc.present(calendarJourney)
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

public struct DatePickerView: View {
    let continueAction: ReferenceAction
    let cancelAction: ReferenceAction
    @Binding var date: Date
    let config: hDatePickerField.HDatePickerFieldConfig

    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        date: Binding<Date>,
        config: hDatePickerField.HDatePickerFieldConfig
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._date = date
        self.config = config
    }

    public var body: some View {
        hForm {
            hSection {
                HStack {
                    if config.showAsList ?? false {
                        datePicker
                            .datePickerStyle(.wheel)
                            .padding(.trailing, 23)
                            .padding(.bottom, 16)
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
                    continueAction.execute()
                } content: {
                    hText(
                        config.buttonText ?? L10n.generalSaveButton,
                        style: .body
                    )
                    .foregroundColor(hTextColor.negative)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)

                hButton.LargeButton(type: .ghost) {
                    cancelAction.execute()
                } content: {
                    hText(
                        L10n.generalCancelButton,
                        style: .body
                    )
                    .foregroundColor(hTextColor.primary)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    hText(config.title)
                    if let subtitle = date.displayDateDDMMMYYYYFormat, !(config.showAsList ?? false) {
                        hText(subtitle).foregroundColor(hTextColor.secondary)
                    }
                }
            }
        }
    }

    private var datePicker: some View {
        let minDate = config.minDate
        let maxDate = config.maxDate
        if let minDate, let maxDate {
            return DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                in: minDate...maxDate,
                displayedComponents: [.date]
            )
        } else if let minDate {
            return DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                in: minDate...,
                displayedComponents: [.date]
            )
        } else if let maxDate {
            return DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                in: ...maxDate,
                displayedComponents: [.date]
            )
        } else {
            return DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
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

public class ReferenceAction {
    var execute: () -> (Void)

    public init(
        execute: @escaping () -> Void
    ) {
        self.execute = execute
    }
}

public enum DateFormatter {
    case DDMMMYYYY
    case birthDate
}
