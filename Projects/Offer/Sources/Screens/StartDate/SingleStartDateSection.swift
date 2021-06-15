import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct SingleStartDateSection {
	let title: String?
	let switchingActivated: Bool
	let isCollapsible: Bool

	private var headerView: UIView? {
		if let title = title {
			let label = UILabel(value: title, style: .brand(.subHeadline(color: .secondary)))
			let stackView = UIStackView()
			stackView.addArrangedSubview(label)
			return stackView
		}
		return nil
	}
}

extension SingleStartDateSection: Presentable {
	func materialize() -> (SectionView, ReadWriteSignal<Date?>) {
		let dateSignal = ReadWriteSignal<Date?>(Date())

		let section = SectionView(headerView: headerView, footerView: nil)
		let bag = DisposeBag()
		let row = RowView(title: "Start date")
		row.prepend(UIView(frame: .init(x: 0, y: 0, width: 17, height: 1)))
		row.prepend(hCoreUIAssets.calendar.image.imageView(height: 21, width: 21))

		let valueLabel = UILabel(value: "", style: .brand(.body(color: .link)))
		row.append(valueLabel)

		bag += dateSignal.atOnce()
			.onValue { date in
				guard let date = date else {
					valueLabel.value = "When current plan expires"
					valueLabel.style = .brand(.body(color: .secondary))
					return
				}

				valueLabel.value = date.localDateStringWithToday ?? ""
				valueLabel.style = .brand(.body(color: .link))
			}

		let picker = UIDatePicker()
		picker.date = Date()
		picker.minimumDate = Date()
		picker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
		picker.calendar = Calendar.current
		picker.datePickerMode = .date
		picker.tintColor = .tint(.lavenderOne)
		if #available(iOS 14.0, *) { picker.preferredDatePickerStyle = .inline }

		bag += dateSignal.atOnce()
			.onValue({ date in
				picker.date = date ?? Date()
			})

		bag += picker.distinct()
			.onValue { date in
				dateSignal.value = date
			}

		let (collapsibleScrollView, isExpandedSignal) = UIScrollView.makeCollapsible(
			picker,
			initiallyCollapsed: isCollapsible
		)
		bag += isExpandedSignal.nil()

		let rowAndCallbacker = section.append(row)

		if isCollapsible {
			bag += dateSignal.atOnce()
				.animated(style: .easeOut(duration: 0.25)) { date in
					if date == nil {
						row.alpha = 0.5
					} else {
						row.alpha = 1
					}
				}
				.onValueDisposePrevious({ date in
					if date != nil {
						return rowAndCallbacker.onValue {
							isExpandedSignal.value = !isExpandedSignal.value
						}
					}

					isExpandedSignal.value = false

					return NilDisposer()
				})
		}

		section.append(collapsibleScrollView)

		let switcherRow = RowView(title: "When current plan expires")
		switcherRow.prepend(UIView(frame: .init(x: 0, y: 0, width: 17, height: 1)))
		switcherRow.prepend(hCoreUIAssets.circularClock.image.imageView(height: 21, width: 21))

		let switcherSwitch = UISwitch()
		bag += dateSignal.atOnce().map { date in date == nil }.bindTo(switcherSwitch)

		bag += switcherSwitch.distinct()
			.onValue { active in
				if active {
					dateSignal.value = nil
				} else {
					dateSignal.value = Date()
				}
			}
		switcherRow.append(switcherSwitch)

		let switcherExplanationRow = RowView(
			title: "Your Hedvig insurance will automatically start when your current plan expires.",
			style: .brand(.footnote(color: .tertiary))
		)

		if switchingActivated {
			section.append(switcherRow)
			section.append(switcherExplanationRow)
		}

		return (section, dateSignal.hold(bag))
	}
}
