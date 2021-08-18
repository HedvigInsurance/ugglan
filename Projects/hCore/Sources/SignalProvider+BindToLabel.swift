import Flow
import Form
import Foundation
import UIKit

extension SignalProvider where Value == DisplayableString {
    public func bindTo(_ label: UILabel) -> Disposable { bindTo(label, \.value) }
}
