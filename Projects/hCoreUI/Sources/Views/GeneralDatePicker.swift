import SwiftUI
import hCore

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
                            .tint(hSignalColor.Green.element)
                            .datePickerStyle(.graphical)
                            .frame(height: 340)
                            .introspectDatePicker { [weak vm] datePicker in
                                vm?.datePicker = datePicker
                                vm?.updateColors()
                            }
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

#Preview{
    @State var date = Date()
    return VStack {
        DatePickerView(
            vm:
                .init(
                    continueAction: {},
                    cancelAction: {},
                    date: $date,
                    config: .init(
                        placeholder: "PLACEHOLDER",
                        title: "TITLE"
                    )
                )
        )
    }
}

public class DatePickerViewModel: ObservableObject, Equatable, Identifiable {
    public static func == (lhs: DatePickerViewModel, rhs: DatePickerViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    public var id: String?
    private var observation: NSKeyValueObservation?
    let continueAction: ReferenceAction
    let cancelAction: ReferenceAction
    weak var datePicker: UIDatePicker?
    @Binding var date: Date
    @Published var dateSelected: Date {
        didSet {
            date = dateSelected
            updateColors()
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

    func updateColors() {
        if let datePicker {
            if let datePickerSubviews = datePicker.subviews.first?.subviews.first?.subviews.first?.subviews,
                datePickerSubviews.count > 2
            {
                let header = datePickerSubviews[0]
                configure(header: header)
                let weekdays = datePickerSubviews[1]
                configure(sectionHeader: weekdays)
                if let dates = datePickerSubviews[2] as? UICollectionView {
                    update(collection: dates)
                }
            }
        }

    }
    /// labels representing days (mon, tue...)
    private func configure(sectionHeader: UIView) {
        let daysColor = UIColor(
            light: hTextColor.Opaque.tertiary.colorFor(.light, .base).color.uiColor(),
            dark: hTextColor.Opaque.tertiary.colorFor(.dark, .base).color.uiColor()
        )
        for subview in sectionHeader.subviews {
            if let subview = subview.subviews.first as? UILabel {
                subview.textColor = daysColor
            }
        }
    }
    /// buttons for previous, next month
    private func configure(header: UIView) {
        let buttonsColor = UIColor(
            light: hFillColor.Opaque.secondary.colorFor(.light, .base).color.uiColor(),
            dark: hFillColor.Opaque.secondary.colorFor(.dark, .base).color.uiColor()
        )
        let textColor = UIColor(
            light: hTextColor.Opaque.primary.colorFor(.light, .base).color.uiColor(),
            dark: hTextColor.Opaque.primary.colorFor(.dark, .base).color.uiColor()
        )
        let buttons = header.subviews.filter({ $0.isKind(of: UIButton.self) })
        for button in buttons {
            if let button = button as? UIButton {
                button.tintColor = buttonsColor
            }
        }

        //current year + month label
        for button in buttons.filter({ $0.subviews.count > 1 }) {
            if let label = button.subviews[1].subviews.first as? UILabel {
                label.textColor = textColor
            }
        }

    }

    private func update(collection: UICollectionView) {
        //iterate through collection sections and find the proper cells for date picker
        for sectionId in 0...collection.numberOfSections - 1 {
            if collection.numberOfItems(inSection: sectionId) > 0 {
                for i in 0...collection.numberOfItems(inSection: sectionId) - 1 {
                    if let cell = collection.cellForItem(at: .init(item: i, section: sectionId)) {
                        //when we find the cell which represent selected date
                        //set background color and text color to proper one
                        if let contentView = cell.subviews.first?.subviews.first?.subviews,
                            let backgroundView = contentView.first, contentView.count > 1
                        {
                            if !backgroundView.isHidden {
                                if let label = cell.subviews.first?.subviews.first?.subviews[1] as? UILabel {
                                    if UIColor.clear != backgroundView.backgroundColor! {
                                        let bgColor = hSignalColor.Green.element
                                            .colorFor(
                                                .init(UITraitCollection.current.userInterfaceStyle) ?? .light,
                                                .base
                                            )
                                            .color.uiColor()
                                        let textColor = hTextColor.Opaque.white.colorFor(.light, .base).color.uiColor()
                                        //when the background color of the selected date changes (by the system) - we want to set it to the proper one
                                        observation = backgroundView.observe(\.backgroundColor) {
                                            [weak label] view, value in
                                            if view.backgroundColor != bgColor && view.backgroundColor != UIColor.clear
                                            {
                                                view.backgroundColor = bgColor
                                                label?.textColor = textColor
                                            }
                                        }

                                        backgroundView.backgroundColor = bgColor
                                        label.textColor = textColor
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
