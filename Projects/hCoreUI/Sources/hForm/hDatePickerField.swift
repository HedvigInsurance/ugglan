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

            hFieldContainer(
                placeholder: config.placeholder,
                customLabelOffset: !(selectedDate?.localDateString.isEmpty ?? true),
                animate: $animate,
                error: $error,
                shouldMoveLabel: shouldMoveLabel
            ) {
                getValueLabel()
            }
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
        .accessibilityAddTraits(.isButton)
        .accessibilityElement(children: .combine)
        .disabled(!isEnabled)
        .detent(
            item: $datePickerNavigationModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
                .embededInNavigation(options: .largeNavigationBar, tracking: self)
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

extension hDatePickerField: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: DatePickerView.self)
    }
}
