import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore

struct SingleStartDateSection {
	let title: String?
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
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(headerView: headerView, footerView: nil)
		let bag = DisposeBag()
		let row = RowView(title: "Start date")
		let pickerExpandedSignal = ReadWriteSignal(false)

		bag += section.append(row).flatMapLatest { _ in pickerExpandedSignal }
			.map { pickerExpanded in !pickerExpanded }.bindTo(pickerExpandedSignal)
		let picker = UIDatePicker()
		picker.minimumDate = Date()
		picker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
		picker.calendar = Calendar.current
		picker.datePickerMode = .date
		picker.tintColor = .tint(.lavenderOne)
		if #available(iOS 14.0, *) { picker.preferredDatePickerStyle = .inline }
		bag += pickerExpandedSignal.atOnce()
			.animated(style: SpringAnimationStyle.lightBounce()) { isExpanded in
				picker.snp.remakeConstraints { make in
					if !isExpanded { make.height.equalTo(0) } else { make.height.equalTo(300) }
				}
				picker.layoutIfNeeded()
				picker.layoutSuperviewsIfNeeded()
			}
		section.append(picker)

		return (section, bag)
	}
}
