import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
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
                            .padding(.bottom, .padding16)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                    } else {
                        datePicker
                            .tint(hSignalColor.Green.element)
                            .datePickerStyle(.graphical)
                            .frame(height: 340)
                            .introspect(.datePicker, on: .iOS(.v13...)) { [weak vm] datePicker in
                                vm?.datePicker = datePicker
                                vm?.updateColors()
                            }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            VStack {
                hButton(
                    .large,
                    .primary,
                    content: .init(
                        title: vm.config.buttonText ?? L10n.generalSaveButton
                    ),
                    {
                        vm.continueAction.execute()
                    }
                )
                .hUseButtonTextColor(.negative)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding(.horizontal, .padding16)

                hCancelButton {
                    vm.cancelAction.execute()
                }
                .sectionContainerStyle(.transparent)
            }
            .padding(.top, .padding8)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    hText(vm.config.title)
                    if !(vm.config.showAsList ?? false) {
                        hText(vm.dateSelected.displayDateDDMMMYYYYFormat).foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
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

struct DatePickerView_Previews: PreviewProvider {
    @State static var date = Date()
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        return VStack {
            DatePickerView(
                vm:
                    .init(
                        continueAction: {},
                        cancelAction: {},
                        date: $date,
                        config: .init(
                            placeholder: "PLACEHOLDER",
                            title: "TITLE",
                            showAsList: true
                        )
                    )
            )
        }
    }
}

@MainActor
public class DatePickerViewModel: ObservableObject, @preconcurrency Equatable, @preconcurrency Identifiable {
    public static func == (lhs: DatePickerViewModel, rhs: DatePickerViewModel) -> Bool {
        lhs.id == rhs.id
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

        dateSelected = date.wrappedValue
        _date = date
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
        _date = date
        dateSelected = date.wrappedValue
        self.config = config
    }

    @MainActor
    func updateColors() {
        if #available(iOS 18.0, *) {
        } else {
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
    }

    /// labels representing days (mon, tue...)
    @MainActor
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
    @MainActor
    private func configure(header: UIView) {
        let buttonsColor = UIColor(
            light: hFillColor.Opaque.secondary.colorFor(.light, .base).color.uiColor(),
            dark: hFillColor.Opaque.secondary.colorFor(.dark, .base).color.uiColor()
        )
        let textColor = UIColor(
            light: hTextColor.Opaque.primary.colorFor(.light, .base).color.uiColor(),
            dark: hTextColor.Opaque.primary.colorFor(.dark, .base).color.uiColor()
        )
        let buttons = header.subviews.filter { $0.isKind(of: UIButton.self) }
        for button in buttons {
            if let button = button as? UIButton {
                button.tintColor = buttonsColor
            }
        }

        // current year + month label
        for button in buttons.filter({ $0.subviews.count > 1 }) {
            if let label = button.subviews[1].subviews.first as? UILabel {
                label.textColor = textColor
                label.font = Fonts.fontFor(style: .heading1)
            }
        }
    }

    @MainActor
    private func update(collection: UICollectionView) {
        // iterate through collection sections and find the proper cells for date picker
        for sectionId in 0...collection.numberOfSections - 1 {
            if collection.numberOfItems(inSection: sectionId) > 0 {
                for i in 0...collection.numberOfItems(inSection: sectionId) - 1 {
                    if let cell = collection.cellForItem(at: .init(item: i, section: sectionId)) {
                        // when we find the cell which represent selected date
                        // set background color and text color to proper one
                        if let contentView = cell.subviews.first?.subviews.first?.subviews,
                            let backgroundView = contentView.first, contentView.count > 1
                        {
                            if !backgroundView.isHidden {
                                if let label = cell.subviews.first?.subviews.first?.subviews[1] as? UILabel {
                                    if UIColor.clear != backgroundView.backgroundColor {
                                        let bgColor = hSignalColor.Green.element
                                            .colorFor(
                                                .init(UITraitCollection.current.userInterfaceStyle) ?? .light,
                                                .base
                                            )
                                            .color.uiColor()
                                        let textColor = hTextColor.Opaque.white.colorFor(.light, .base).color.uiColor()
                                        // when the background color of the selected date changes (by the system) - we want to set it to the proper one
                                        observation = backgroundView.observe(\.backgroundColor) {
                                            [weak label] view, _ in
                                            Task { @MainActor in
                                                if view.backgroundColor != bgColor,
                                                    view.backgroundColor != UIColor.clear
                                                {
                                                    view.backgroundColor = bgColor
                                                    label?.textColor = textColor
                                                }
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
            title: "Departure date",
            showAsList: true
        )
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })

        return VStack {
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
    var execute: () -> Void

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

extension DatePickerView: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: DatePickerView.self)
    }
}
