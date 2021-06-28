import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct MultiActionTable {
	let state: EmbarkState
	var components: [MultiActionComponent]
	let title: String?
	@ReadWriteState var multiActionValues = [String: MultiActionValue]()
}

extension MultiActionTable: Presentable {
	func materialize() -> (UIViewController, FiniteSignal<[String: MultiActionValue]>) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let form = FormView()

		let section = form.appendSection()
		section.dynamicStyle = .brandGroupedNoBackground

		bag += form.traitCollectionSignal.onValue { trait in
			switch trait.userInterfaceStyle {
			case .dark: form.backgroundColor = .grayscale(.grayFive)
			default: form.backgroundColor = .brand(.primaryBackground())
			}
		}
        
		viewController.title = title

		func addDividerIfNeeded(index: Int) {
			let endIndex = components.endIndex
			let isLastComponent: Bool = index == endIndex - 1

			if !isLastComponent {
				let color =
					form.traitCollection.userInterfaceStyle == .light
					? UIColor.brand(.primaryBorderColor) : .brand(.primaryBorderColor)
				let divider = Divider(backgroundColor: color)
				bag += section.append(divider)
			}
		}

		func addValues(storeValues: [String: MultiActionValue]) {
			$multiActionValues.value = $multiActionValues.value.merging(
				storeValues,
				uniquingKeysWith: takeRight
			)
		}

		func addNumberAction(_ data: EmbarkNumberMultiActionData, index: Int) {
			let numberAction = MultiActionNumberRow(data: data)

			bag += section.append(numberAction) { _ in addDividerIfNeeded(index: index) }
				.onValue { addValues(storeValues: $0) }
		}

		func addDropDownAction(_ data: EmbarkDropDownActionData, index: Int) {
			let dropDownAction = MultiActionDropDownRow(data: data)

			bag += section.append(dropDownAction) { _ in addDividerIfNeeded(index: index) }
				.onValue { addValues(storeValues: $0) }
		}

		func addSwitchAction(_ data: EmbarkSwitchActionData, index: Int) {
			let switchAction = MultiActionSwitchRow(data: data)

			bag += section.append(switchAction) { _ in addDividerIfNeeded(index: index) }
				.onValue { addValues(storeValues: $0) }
		}

		components.enumerated()
			.forEach { index, component in
				switch component {
				case let .number(data): addNumberAction(data, index: index)
				case let .dropDown(data): addDropDownAction(data, index: index)
				case let .switch(data): addSwitchAction(data, index: index)
				case .empty: break
				}
			}

        func didCompleteForm() -> Bool { $multiActionValues.value.allSatisfy { $1.isValid } }

		bag += section.append(Spacing(height: 16))

		section.backgroundColor = .clear
		bag += viewController.currentDetentSignal.animated(style: .lightBounce()) { _ in
			viewController.view.layoutIfNeeded()
		}
        
        let button = Button(
            title: L10n.generalSaveButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            ),
            isEnabled: false
        )
        
        let buttonStack = UIStackView()
        buttonStack.edgeInsets = .init(
            top: 0,
            left: 16,
            bottom: 16 + viewController.view.safeAreaInsets.bottom,
            right: 16
        )
        bag += buttonStack.addArranged(button)
        
        bag += viewController.install(form) { scrollView in
            bag += scrollView.embedPinned(buttonStack, edge: .bottom, minHeight: 44)
        }
        
        bag += $multiActionValues.map { _ in didCompleteForm() }.bindTo(button.isEnabled)

		return (
			viewController,
			FiniteSignal { callback in func submit() { callback(.value($multiActionValues.value)) }

				let cancelButton = UIButton()
				let textStyle = TextStyle.brand(.body(color: .primary))
				let attributedTitle = NSAttributedString(
					string: L10n.generalCancelButton,
					attributes: textStyle.attributes
				)
				cancelButton.setAttributedTitle(attributedTitle, for: .normal)

				bag += cancelButton.signal(for: .touchUpInside).onValue { _ in callback(.end) }

				viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(button: cancelButton)

				bag += button.onTapSignal.onValue { _ in submit() }

				return bag
			}
		)
	}
}

internal struct MultiActionValue {
	var inputValue: String
	var displayValue: String?
    var isValid = false
}

typealias EmbarkDropDownActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction
	.MultiActionDatum.Component.AsEmbarkDropdownAction.DropDownActionDatum

typealias EmbarkSwitchActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction
	.MultiActionDatum.Component.AsEmbarkSwitchAction.SwitchActionDatum

typealias EmbarkNumberMultiActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction
    .MultiActionDatum.Component.AsEmbarkMultiActionNumberAction.NumberActionDatum

internal typealias MultiActionStoreSignal = Signal<[String: MultiActionValue]>

internal enum MultiActionComponent { case number(EmbarkNumberMultiActionData)
	case dropDown(EmbarkDropDownActionData)
	case `switch`(EmbarkSwitchActionData)
	case empty
}
