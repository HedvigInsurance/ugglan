import Flow
import Foundation
import UIKit

struct DynamicString: SignalProvider {
    var providedSignal = ReadWriteSignal<String>("")

    var value: String {
        get { providedSignal.value }
        set(newValue) { providedSignal.value = newValue }
    }

    init(_ value: String = "") { self.value = value }
}

extension UILabel {
    func setDynamicText(_ dynamicText: DynamicString) -> Disposable {
        let bag = DisposeBag()
        text = dynamicText.value

        bag += dynamicText.onValue { newValue in self.text = newValue }

        return bag
    }
}
