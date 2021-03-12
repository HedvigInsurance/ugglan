import Flow
import Form
import Foundation
import UIKit

public extension SignalProvider where Value == DisplayableString {
    func bindTo(_ label: UILabel) -> Disposable {
        bindTo(label, \.value)
    }
}
