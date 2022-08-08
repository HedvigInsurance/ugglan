import Foundation
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct BottomAttachedSignButton: Presentable {
    func materialize() -> (UIView, Disposable) {
        let form = FormView()
        form.dynamicStyle = DynamicFormStyle { _ in
            .init(insets: .zero)
        }
        form.insetsLayoutMarginsFromSafeArea = true
        
        let bag = DisposeBag()
        
        bag += form.append(SignSection())
        
        return (form, bag)
    }
}
