//
//  ReflectionForm.swift
//  ForeverExample
//
//  Created by sam on 11.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import Runtime
import UIKit

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

        bag += amountRow.append(
            UITextField(value: monetaryAmount.amount, placeholder: "0.0", style: .default)
        ).onValue { value in
            monetaryAmount.amount = value
            setValue(monetaryAmount)
        }

        let currencyRow = section.appendRow(title: "Currency")
        bag += currencyRow.append(
            UITextField(value: monetaryAmount.currency, placeholder: "SEK", style: .default)
        ).onValue { value in
            monetaryAmount.amount = value
            setValue(monetaryAmount)
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
            bag += section.append(row).onValue { _ in
                viewController.present(ArrayItemForm(item: item, type: type), style: .default, options: [.defaults, .autoPop]).onValue { updatedItem in
                    list.append(updatedItem)
                    setValue(list)
                }
            }
        }

        list.enumerated().forEach { offset, item in
            guard
                let info = try? typeInfo(of: property.type),
                let elementType = info.genericTypes.first,
                let item = item as? (Decodable & Encodable) else {
                fatalError("Failed to parse array item")
            }

            renderRow(item: item, type: elementType, offset: offset)
        }

        let createRow = RowView(title: "Create new")

        createRow.append(.chevron)

        bag += section.append(createRow).onValue { _ in
            guard
                let info = try? typeInfo(of: property.type),
                let elementType = info.genericTypes.first,
                let arrayElementInstance = try? createInstance(of: elementType) as? (Decodable & Encodable) else {
                fatalError("Failed to create instance for array")
            }

            viewController.present(ArrayItemForm(item: arrayElementInstance, type: elementType), style: .default, options: [.defaults, .autoPop]).onValue { item in
                list.append(item)
                setValue(list)

                renderRow(item: item, type: elementType, offset: list.endIndex)
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

        bag += row.append(
            UITextField(value: string, placeholder: "value", style: .default)
        ).onValue { value in
            setValue(value)
        }

        return (section, bag)
    } else if let boolean = try? property.get(from: typeInstance) as? Bool {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: UILabel(value: property.name, style: .default),
            footerView: UILabel(value: "", style: .default)
        )

        let currencyRow = section.appendRow(title: "boolean")
        bag += currencyRow.append(UISwitch(value: boolean)).onValue { value in
            setValue(value)
        }

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

struct ArrayItemForm: Presentable {
    let item: AnyCodable
    let type: Any.Type

    func materialize() -> (UIViewController, Future<AnyCodable>) {
        let viewController = UIViewController()
        viewController.title = "Create new"

        let bag = DisposeBag()
        let form = FormView()

        var itemCopy = item

        if let info = try? typeInfo(of: type) {
            bag += info.properties.map { property in
                let (section, bag) = getSection(for: property, typeInstance: item, in: viewController) { value in
                    try? property.set(value: value, on: &itemCopy)
                }

                form.append(section)

                return bag
            }
        }

        let button = Button(
            title: "Save",
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )
        bag += form.append(button)

        bag += viewController.install(form) { scrollView in
            bag += scrollView.chainAllControlResponders(
                shouldLoop: false,
                returnKey: .next
            )
        }

        return (viewController, Future<AnyCodable> { completion in
            bag += button.onTapSignal.onValue {
                completion(.success(itemCopy))
            }

            return bag
               })
    }
}

struct ReflectionForm<T: Codable> {
    let editInstance: T?
    let title: String
}

extension ReflectionForm: Presentable {
    func materialize() -> (UIViewController, Future<T>) {
        let viewController = UIViewController()
        viewController.title = "Create new"

        let bag = DisposeBag()
        let form = FormView()

        guard var typeInstance = editInstance ?? (try? createInstance(of: T.self) as? T) else {
            fatalError("Couldn't create instance of type \(T.self)")
        }

        if let info = try? typeInfo(of: T.self) {
            bag += info.properties.map { property in
                let (section, bag) = getSection(for: property, typeInstance: typeInstance, in: viewController) { value in
                    try? property.set(value: value, on: &typeInstance)
                }

                form.append(section)

                return bag
            }
        }

        let button = Button(
            title: "Save",
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )
        bag += form.append(button)

        bag += viewController.install(form) { scrollView in
            bag += scrollView.chainAllControlResponders(
                shouldLoop: false,
                returnKey: .next
            )
        }

        return (viewController, Future<T> { completion in
            bag += button.onTapSignal.onValue {
                if self.editInstance == nil {
                    ReflectionFormHistory<T>(title: self.title).appendItem(typeInstance)
                }
                completion(.success(typeInstance))
            }

            return bag
        })
    }
}
