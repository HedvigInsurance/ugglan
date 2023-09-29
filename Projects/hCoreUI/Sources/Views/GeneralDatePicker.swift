import SwiftUI
import hCore

public struct GeneralDatePicker: View {
    @State private var dateOfOccurrence = Date()

    private let model: GeneralDatePickerViewModel

    public init(_ model: GeneralDatePickerViewModel) {
        self.model = model
        dateOfOccurrence = model.selectedDate ?? Date()
    }

    public var body: some View {
        hForm {
            hSection {
                getDatePicker
                    .environment(\.locale, Locale.init(identifier: Localization.Locale.currentLocale.rawValue))
                    .datePickerStyle(.graphical)
                    .padding([.leading, .trailing], 16)
                    .padding([.top], 5)
            }
        }
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButton(type: .primary) {
                    model.onDateSelected(dateOfOccurrence)
                } content: {
                    hText(model.buttonTitle, style: .body)
                        .foregroundColor(hTextColorNew.primary.inverted)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(model.title)
    }

    @ViewBuilder
    private var getDatePicker: some View {
        let minDate = model.minDate
        let maxDate = model.maxDate
        if let minDate, let maxDate {
            DatePicker(
                model.title,
                selection: self.$dateOfOccurrence,
                in: minDate...maxDate,
                displayedComponents: [.date]
            )
        } else if let minDate {
            DatePicker(
                model.title,
                selection: self.$dateOfOccurrence,
                in: minDate...,
                displayedComponents: [.date]
            )
        } else if let maxDate {
            DatePicker(
                model.title,
                selection: self.$dateOfOccurrence,
                in: ...maxDate,
                displayedComponents: [.date]
            )
        } else {
            DatePicker(
                model.title,
                selection: self.$dateOfOccurrence,
                displayedComponents: [.date]
            )
        }
    }
}

struct GeneralDatePicker_Previews: PreviewProvider {
    static let model = GeneralDatePickerViewModel(title: "", buttonTitle: "") { _ in

    }
    static var previews: some View {
        GeneralDatePicker(model)
    }
}

public struct GeneralDatePickerViewModel {
    let title: String
    let buttonTitle: String
    let onDateSelected: (_ date: Date) -> Void
    let minDate: Date?
    let maxDate: Date?
    let selectedDate: Date?

    public init(
        title: String,
        buttonTitle: String,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        selectedDate: Date? = nil,
        onDateSelected: @escaping (_: Date) -> Void
    ) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.onDateSelected = onDateSelected
        self.minDate = minDate
        self.maxDate = maxDate
        self.selectedDate = selectedDate

    }
}
