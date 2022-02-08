import Foundation
import SwiftUI
import UIKit

public struct DatePicker: UIViewRepresentable {
    public init(
        date: Binding<Date>,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        calendar: Calendar,
        datePickerMode: UIDatePicker.Mode
    ) {
        self._date = date
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.calendar = calendar
        self.datePickerMode = datePickerMode
    }

    @Binding var date: Date
    var minimumDate: Date?
    var maximumDate: Date?
    var calendar: Calendar
    var datePickerMode: UIDatePicker.Mode

    public class Coordinator {
        private let date: Binding<Date>

        init(
            date: Binding<Date>
        ) {
            self.date = date
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            self.date.wrappedValue = sender.date
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }

    public func makeUIView(context: Context) -> some UIView {
        let picker = UIDatePicker()

        if #available(iOS 14.0, *) { picker.preferredDatePickerStyle = .inline }

        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged),
            for: .valueChanged
        )

        picker.tintColor = .tint(.lavenderOne)

        return picker
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let datePicker = uiView as? UIDatePicker {
            datePicker.minimumDate = minimumDate
            datePicker.maximumDate = maximumDate
            datePicker.calendar = calendar
            datePicker.datePickerMode = datePickerMode
            datePicker.date = date
        }
    }
}
