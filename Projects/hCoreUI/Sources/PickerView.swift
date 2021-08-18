import Flow
import Presentation
import UIKit
import hCore

public struct PickerView {
    public init(
        options: [String]
    ) {
        self.options = options
    }

    let options: [String]
    let didSelectSignal = ReadWriteSignal<String>("")
    let resignationSignal = ReadWriteSignal<Bool>(false)

    private class PickerDelegateHandler: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        internal init(
            options: [String],
            onSelect: @escaping (String) -> Void
        ) {
            self.options = options
            self.onSelect = onSelect
        }

        let options: [String]
        let onSelect: (_ value: String) -> Void

        func numberOfComponents(in _: UIPickerView) -> Int { 1 }

        func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int { options.count }

        func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) { onSelect(options[row]) }

        func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? { options[row] }
    }
}

extension PickerView: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIPickerView, ReadSignal<String>) {
        let bag = DisposeBag()
        let pickerView = UIPickerView()

        let pickerHandler = PickerDelegateHandler(options: options) { option in didSelectSignal.value = option }

        bag.hold(pickerHandler)

        pickerView.delegate = pickerHandler
        pickerView.dataSource = pickerHandler

        return (pickerView, didSelectSignal.readOnly().hold(bag))
    }
}
