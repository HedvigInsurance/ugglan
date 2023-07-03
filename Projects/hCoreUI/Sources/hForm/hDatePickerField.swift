import Flow
import Presentation
import SwiftUI
import hCore

public struct hDatePickerField: View {
    private let config: HDatePickerFieldConfig
    private let onUpdate: (_ date: Date) -> Void
    private let onContinue: (_ date: Date) -> Void
    @State private var animate = false
    @State private var date = Date()
    @Binding private var selectedDate: Date?
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
        selectedDate: Binding<Date?>,
        error: Binding<String?>? = nil,
        onUpdate: @escaping (_ date: Date) -> Void = { _ in },
        onContinue: @escaping (_ date: Date) -> Void = { _ in }
    ) {
        self.config = config
        self.onUpdate = onUpdate
        self.onContinue = onContinue
        self._selectedDate = selectedDate
        self._error = error ?? Binding.constant(nil)
        self.date = selectedDate.wrappedValue ?? Date()
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
        .padding(.vertical, 10 - HFontTextStyleNew.title3.uifontLineHeightDifference)
        .onChange(of: date) { date in
            selectedDate = date
        }
        .onChange(of: selectedDate) { date in
            if let date {
                onUpdate(date)
            }
        }
        .addFieldBackground(animate: $animate, error: $error)
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
            Text(selectedDate?.localDateString ?? L10n.generalSelectButton)
                .modifier(hFontModifierNew(style: .title3))
                .foregroundColor(hLabelColorNew.primary)
            Spacer()
        }

    }

    private func showDatePicker() {
        let referenceAction = ReferenceAction {}
        let view = DatePickerView(action: referenceAction, date: $date)
        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: .prefersNavigationBarHidden(true)
        )
        .withDismissButton

        let calendarJourney = journey.addConfiguration { presenter in
            referenceAction.execute = {
                self.onContinue(date)
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

        public init(
            minDate: Date? = nil,
            maxDate: Date? = nil,
            placeholder: String
        ) {
            self.minDate = minDate
            self.maxDate = maxDate
            self.placeholder = placeholder
        }
    }
}

private struct DatePickerView: View {
    fileprivate let action: ReferenceAction
    @Binding fileprivate var date: Date
    public var body: some View {
        ScrollView {
            hForm {
                hSection {
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .frame(height: 350)
                }
                .sectionContainerStyle(.transparent)
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    action.execute()
                } content: {
                    hText(
                        L10n.generalContinueButton,
                        style: .body
                    )
                    .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)
            }
            .hUseNewStyle
        }
    }
}

struct hDatePickerField_Previews: PreviewProvider {
    @State private static var date: Date?
    private static let config = hDatePickerField.HDatePickerFieldConfig(
        placeholder: "Placeholder"
    )
    static var previews: some View {
        hDatePickerField(config: config, selectedDate: $date)
    }
}

private class ReferenceAction {
    var execute: () -> (Void)

    init(
        execute: @escaping () -> Void
    ) {
        self.execute = execute
    }
}
