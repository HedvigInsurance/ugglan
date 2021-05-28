import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct MultiActionDropDownRow {
    let data: EmbarkDropDownActionData
    let isExpanded = ReadWriteSignal<Bool>(false)
}

extension MultiActionDropDownRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
        let bag = DisposeBag()

        let containerView = UIView()
        bag += containerView.traitCollectionSignal.onValue { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                containerView.backgroundColor = .grayscale(.grayFive)
            default:
                containerView.backgroundColor = .brand(.primaryBackground())
            }
        }

        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.distribution = .fill

        containerView.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.spacing = 10
        topStack.edgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        topStack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        topStack.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label

        let options = data.options.map { $0.value }

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 8
        buttonStack.isUserInteractionEnabled = false

        let buttonTitle = UILabel()
        buttonTitle.style = .brand(.body(color: .tertiary))
        buttonTitle.setContentHuggingPriority(.required, for: .vertical)
        buttonTitle.text = "Select"; #warning("need to add to l10n")

        let buttonIcon = UIImageView()
        buttonIcon.image = hCoreUIAssets.chevronUp.image
        buttonIcon.tintColor = .brand(.primaryText())

        buttonStack.addArrangedSubview(buttonTitle)
        buttonStack.addArrangedSubview(buttonIcon)

        let button = UIControl()
        button.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topStack.addArrangedSubview(titleLabel)
        topStack.addArrangedSubview(button)

        mainStack.addArrangedSubview(topStack)
        bag += mainStack.add(Divider(backgroundColor: .brand(.primaryShadowColor)))

        bag += button
            .signal(for: .touchUpInside)
            .withLatestFrom(isExpanded.atOnce().plain()).map { !$1 }
            .bindTo(isExpanded)

        return (containerView, Signal { callback in
            let pickerView = PickerView(options: options)
            bag += mainStack.addArranged(pickerView) { view in
                bag += isExpanded
                    .atOnce()
                    .animated(style: .lightBounce()) { isExpanded in
                        view.isHidden = !isExpanded
                        view.alpha = isExpanded ? 1.0 : 0.0
                        let rotation = CGFloat(180 * Double.pi / 180)
                        let transform = isExpanded ? CGAffineTransform.identity : .init(rotationAngle: rotation)
                        buttonIcon.transform = transform
                    }
            }.map { option in
                data.options.first(where: { $0.value == option })
            }.onValue { selectedOption in
                buttonTitle.style = .brand(.body(color: .primary))
                guard let selectedOption = selectedOption else { return }
                buttonTitle.value = selectedOption.value

                let value = MultiActionValue(inputValue: selectedOption.value, displayValue: selectedOption.value)
                callback([data.key: value])
            }

            return bag
        })
    }
}

struct PickerView {
    let options: [String]
    let didSelectSignal = ReadWriteSignal<String>("")
    let resignationSignal = ReadWriteSignal<Bool>(false)

    private class PickerDelegateHandler: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        internal init(options: [String], onSelect: @escaping (String) -> Void) {
            self.options = options
            self.onSelect = onSelect
        }

        let options: [String]
        let onSelect: (_ value: String) -> Void

        func numberOfComponents(in _: UIPickerView) -> Int {
            1
        }

        func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
            options.count
        }

        func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
            onSelect(options[row])
        }

        func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
            options[row]
        }
    }
}

extension PickerView: Viewable {
    func materialize(events _: ViewableEvents) -> (UIPickerView, ReadSignal<String>) {
        let bag = DisposeBag()
        let pickerView = UIPickerView()

        let pickerHandler = PickerDelegateHandler(options: options) { option in
            didSelectSignal.value = option
        }

        bag.hold(pickerHandler)

        pickerView.delegate = pickerHandler
        pickerView.dataSource = pickerHandler

        return (pickerView, didSelectSignal.readOnly().hold(bag))
    }
}
