import Flow
import Presentation
import SwiftUI
import hCore

public struct hDatePickerField: View {
    private let config: HDatePickerFieldConfig
    private let onUpdate: (_ date: Date) -> Void
    private let onContinue: (_ date: Date) -> Void
    @State private var animate = false
    @State private var date: Date = Date()
    private var selectedDate: Date?
    @Binding var error: String?
    @State private var disposeBag = DisposeBag()

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { true },
            set: { _ in }
        )
    }

    public init(
        config: HDatePickerFieldConfig,
        selectedDate: Date?,
        error: Binding<String?>? = nil,
        onContinue: @escaping (_ date: Date) -> Void = { _ in }
    ) {
        self.config = config
        self.onUpdate = { _ in }
        self.onContinue = onContinue
        self.selectedDate = selectedDate
        self._error = error ?? Binding.constant(nil)
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hFieldLabel(
                placeholder: config.placeholder,
                animate: $animate,
                error: $error,
                shouldMoveLabel: shouldMoveLabel
            )
            getValueLabel()
        }
        .padding(.vertical, 5)
        .onChange(of: selectedDate) { date in
            if let date {
                onUpdate(date)
            }
        }
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            showDatePicker()
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }
    }

    private func getValueLabel() -> some View {
        HStack {
            Text(selectedDate?.displayDateDotFormat ?? L10n.generalSelectButton)
                .modifier(hFontModifier(style: .title3))
                .foregroundColor(hTextColorNew.primary)
            Spacer()
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
        let subtitle: String?

        public init(
            minDate: Date? = nil,
            maxDate: Date? = nil,
            placeholder: String,
            title: String,
            subtitle: String?
        ) {
            self.minDate = minDate
            self.maxDate = maxDate
            self.placeholder = placeholder
            self.title = title
            self.subtitle = subtitle
        }
    }
}

private struct DatePickerView: View {
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var date: Date
    let config: hDatePickerField.HDatePickerFieldConfig

    public var body: some View {
        ScrollView {
            hForm {
                hSection {
                    datePicker
                        .datePickerStyle(.graphical)
                        .frame(height: 350)
                }
                .sectionContainerStyle(.transparent)
            }
            .hFormAttachToBottom {
                VStack {
                    hButton.LargeButtonPrimary {
                        continueAction.execute()
                    } content: {
                        hText(
                            L10n.generalContinueButton,
                            style: .body
                        )
                        .foregroundColor(hLabelColor.primary.inverted)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding([.leading, .trailing], 16)

                    hButton.LargeButtonGhost {
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
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    hText(config.title)
                    if let subtitle = config.subtitle {
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
                selection: self.$date,
                in: minDate...maxDate,
                displayedComponents: [.date]
            )
        } else if let minDate {
            DatePicker(
                "",
                selection: self.$date,
                in: minDate...,
                displayedComponents: [.date]
            )
        } else if let maxDate {
            DatePicker(
                "",
                selection: self.$date,
                in: ...maxDate,
                displayedComponents: [.date]
            )
        } else {
            DatePicker(
                "",
                selection: self.$date,
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
            title: "Departure date",
            subtitle: "2023.06.23"
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
