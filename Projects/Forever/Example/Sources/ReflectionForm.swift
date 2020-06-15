//
//  ReflectionForm.swift
//  ForeverExample
//
//  Created by sam on 11.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Forever
import ForeverTesting
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import Runtime
import UIKit

struct ReflectionForm<T> {
    let type: T.Type
    let title: String

    func getSection(
        for property: PropertyInfo,
        typeInstance: Any,
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
            let createButton = Button(
                title: "Create \(property.type)",
                type: .standardSmall(backgroundColor: .black, textColor: .white)
            )

            bag += section.append(createButton.wrappedIn(RowView()))

            bag += createButton.onTapSignal.onValue {
                UIView.animate(withDuration: 0.5) {
                    guard
                        let info = try? typeInfo(of: property.type),
                        let elementType = info.genericTypes.first,
                        var arrayElementInstance = try? createInstance(of: elementType) else {
                        fatalError("Failed to create instance for array")
                    }
                    list.append(arrayElementInstance)
                    let row = UIStackView()
                    row.axis = .vertical

                    if let info = try? typeInfo(of: elementType) {
                        bag += info.properties.map { property in
                            let (rowSection, rowBag) = self.getSection(
                                for: property,
                                typeInstance: arrayElementInstance
                            ) { value in
                                try? property.set(value: value, on: &arrayElementInstance)
                                setValue(list)
                            }

                            row.append(rowSection)

                            return rowBag
                        }
                    }

                    let deleteButton = Button(
                        title: "Delete",
                        type: .standardSmall(backgroundColor: .black, textColor: .white)
                    )

                    bag += row.addArranged(deleteButton)
                    section.prepend(row)

                    bag += deleteButton.onTapSignal.onValue { _ in
                        row.removeFromSuperview()
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
}

extension ReflectionForm: Presentable {
    func materialize() -> (UIViewController, Signal<T>) {
        let viewController = UIViewController()
        viewController.title = title

        let bag = DisposeBag()

        let form = FormView()

        guard var typeInstance = try? createInstance(of: type) as? T else {
            fatalError("Couldn't create instance of type \(type)")
        }

        if let info = try? typeInfo(of: type) {
            bag += info.properties.map { property in
                let (section, bag) = getSection(for: property, typeInstance: typeInstance) { value in
                    try? property.set(value: value, on: &typeInstance)
                }

                form.append(section)

                return bag
            }
        }

        let button = Button(
            title: "Continue",
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )
        bag += form.append(button)

        bag += viewController.install(form)

        return (viewController, Signal<T> { callbacker in
            bag += button.onTapSignal.onValue {
                callbacker(typeInstance)
            }

            return bag
        })
    }
}
