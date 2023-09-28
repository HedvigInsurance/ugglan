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
                if (selectedDate?.displayDateDotFormat) != nil {
                    getValueLabel()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, selectedDate?.localDateString.isEmpty ?? true ? 0 : 10)
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
            Text((selectedDate?.displayDateDotFormat ?? placeholderText) ?? L10n.generalSelectButton)
                .modifier(hFontModifier(style: .title3))
                .foregroundColor(foregroundColor)
            Spacer()
        }
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColorNew.primary
        } else {
            hTextColorNew.secondary
        }
    }

    private func showDatePicker() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}
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
        let placeholder: String
        let title: String

        public init(
            minDate: Date? = nil,
            maxDate: Date? = nil,
            placeholder: String,
            title: String
        ) {
            self.minDate = minDate
            self.maxDate = maxDate
            self.placeholder = placeholder
            self.title = title
        }
    }
}

private struct DatePickerView: View {
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var date: Date
    let config: hDatePickerField.HDatePickerFieldConfig

    public var body: some View {
        hForm {
            hSection {
                datePicker
                    .datePickerStyle(.graphical)
                    .frame(height: 340)
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
                        L10n.generalSaveButton,
                        style: .body
                    )
                    .foregroundColor(hLabelColor.primary.inverted)
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
                    .foregroundColor(hTextColorNew.primary)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    hText(config.title)
                    if let subtitle = date.displayDateDotFormat {
                        hText(subtitle).foregroundColor(hTextColorNew.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var datePicker: some View {
        let minDate = config.minDate
        let maxDate = config.maxDate
        if let minDate, let maxDate {
            DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                in: minDate...maxDate,
                displayedComponents: [.date]
            )
        } else if let minDate {
            DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                in: minDate...,
                displayedComponents: [.date]
            )
        } else if let maxDate {
            DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                in: ...maxDate,
                displayedComponents: [.date]
            )
        } else {
            DatePicker(
                "",
                selection: self.$date.animation(.easeInOut(duration: 0.2)),
                displayedComponents: [.date]
            )
        }
    }
}

struct hDatePickerField_Previews: PreviewProvider {
    @State private static var date: Date?
    private static let config =
        hDatePickerField
        .HDatePickerFieldConfig(
            placeholder: "Placeholder",
            title: "Departure date"
        )
    static var previews: some View {
        hDatePickerField(config: config, selectedDate: date)
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
