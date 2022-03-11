import Flow
import Form
import Foundation
import Presentation
import Runtime
import UIKit
import hCore
import hCoreUI
import hGraphQL

typealias AnyCodable = (Any & Codable)

func getSection(
    for property: PropertyInfo,
    typeInstance: Any,
    in viewController: UIViewController,
    setValue: @escaping (_ value: Any) -> Void
) -> (SectionView, Disposable) {
    if var monetaryAmount = try? property.get(from: typeInstance) as? MonetaryAmount {
        let bag = DisposeBag()

        let section = SectionView(
            headerView: UILabel(value: property.name, style: .default),
            footerView: UILabel(value: "", style: .default)
        )
        let amountRow = section.appendRow(title: "Amount")

        bag +=
            amountRow.append(
                UITextField(
                    value: monetaryAmount.amount,
                    placeholder: "0.0",
                    style: FieldStyle.default.keyboard(.decimalPad)
                )
            )
            .onValue { value in monetaryAmount.amount = value
                setValue(monetaryAmount)
            }

        let currencyRow = section.appendRow(title: "Currency")
        let currencyValue = UILabel(value: monetaryAmount.currency, style: .brand(.headline(color: .primary)))

        currencyRow.append(currencyValue)

        let pickerView = UIPickerView()
        pickerView.isHidden = true
        pickerView.snp.makeConstraints { make in make.height.equalTo(0) }

        class DataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
            internal init(onSelect: @escaping (String) -> Void) { self.onSelect = onSelect }

            let currencies = ["SEK", "NOK"]
            let onSelect: (_ value: String) -> Void

            func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int { currencies.count }

            func numberOfComponents(in _: UIPickerView) -> Int { 1 }

            func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
                currencies[row]
            }

            func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
                onSelect(currencies[row])
            }
        }

        let dataSource = DataSource { value in currencyValue.value = value
            monetaryAmount.currency = value
            setValue(monetaryAmount)
        }
        bag.hold(dataSource)

        pickerView.dataSource = dataSource
        pickerView.delegate = dataSource

        if let indexOfSelected = dataSource.currencies.firstIndex(where: { $0 == monetaryAmount.currency }) {
            pickerView.selectRow(indexOfSelected, inComponent: 0, animated: false)
        }

        section.append(pickerView)

        bag += currencyRow.animated(style: SpringAnimationStyle.lightBounce()) {
            pickerView.animationSafeIsHidden = !pickerView.animationSafeIsHidden

            if !pickerView.isHidden {
                pickerView.snp.removeConstraints()
            } else {
                pickerView.snp.makeConstraints { make in make.height.equalTo(0) }
            }

            pickerView.layoutIfNeeded()
            pickerView.layoutSuperviewsIfNeeded()
        }

        return (section, bag)
    } else if var list = try? property.get(from: typeInstance) as? [Any] {
        let bag = DisposeBag()

        let section = SectionView(
            headerView: UILabel(value: property.name, style: .default),
            footerView: UILabel(value: "", style: .default)
        )

        func renderRow(item: Decodable & Encodable, type: Any.Type, offset: Int) {
            let row = RowView(title: "\(offset)")
            bag += section.append(row)
                .onValue { _ in
                    viewController.present(
                        ArrayItemForm(item: item, type: type, isEditing: true),
                        style: .default,
                        options: [.defaults, .autoPop]
                    )
                    .onValue { updatedItem in list.append(updatedItem)
                        setValue(list)
                    }
                }
        }

        list.enumerated()
            .forEach { offset, item in
                guard let info = try? typeInfo(of: property.type),
                    let elementType = info.genericTypes.first,
                    let item = item as? (Decodable & Encodable)
                else { fatalError("Failed to parse array item") }

                renderRow(item: item, type: elementType, offset: offset)
            }

        let createRow = RowView(title: "Create new")

        createRow.append(.chevron)

        bag += section.append(createRow)
            .onValue { _ in
                guard let info = try? typeInfo(of: property.type),
                    let elementType = info.genericTypes.first,
                    let arrayElementInstance = try? createInstance(of: elementType)
                        as? (Decodable & Encodable)
                else { fatalError("Failed to create instance for array") }

                viewController.present(
                    ArrayItemForm(item: arrayElementInstance, type: elementType, isEditing: false),
                    style: .default,
                    options: [.defaults, .autoPop]
                )
                .onValue { item in list.append(item)
                    setValue(list)

                    bag += Signal(after: 0)
                        .animated(style: SpringAnimationStyle.lightBounce()) {
                            renderRow(item: item, type: elementType, offset: list.endIndex)
                        }
                }
            }

        return (section, bag)
    } else if let string = try? property.get(from: typeInstance) as? String {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: UILabel(value: property.name, style: .default),
            footerView: UILabel(value: "", style: .default)
        )

        let row = RowView()
        section.append(row)

        bag += row.append(UITextField(value: string, placeholder: "value", style: .default))
            .onValue { value in setValue(value) }

        return (section, bag)
    } else if let boolean = try? property.get(from: typeInstance) as? Bool {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: UILabel(value: property.name, style: .default),
            footerView: UILabel(value: "", style: .default)
        )

        let currencyRow = section.appendRow(title: "boolean")
        bag += currencyRow.append(UISwitch(value: boolean)).onValue { value in setValue(value) }

        return (section, bag)
    } else if let info = try? typeInfo(of: property.type) {
        if info.kind == .enum {
            let bag = DisposeBag()

            let section = SectionView(
                headerView: UILabel(value: property.name, style: .default),
                footerView: UILabel(value: "", style: .default)
            )

            let row = RowView()
            section.append(row)

            let segmentControl = UISegmentedControl(titles: info.cases.map { $0.name })
            segmentControl.value = 0

            if let runtimeEnum = property.type as? RuntimeEnum.Type {
                let caseValue = info.cases[0]
                setValue(runtimeEnum.fromName(caseValue.name))
            }

            row.append(segmentControl)

            bag += segmentControl.onValue { index in
                if let runtimeEnum = property.type as? RuntimeEnum.Type {
                    let caseValue = info.cases[index]
                    setValue(runtimeEnum.fromName(caseValue.name))
                }
            }

            return (section, bag)
        }
    }

    let fallbackSection = SectionView(
        headerView: UILabel(value: "Unknown type: \(property.name)", style: .default),
        footerView: nil
    )

    return (fallbackSection, NilDisposer())
}
