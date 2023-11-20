import hCore
import SwiftUI
import UIKit

extension String: TitleView {
    public func getTitleView() -> UIView {
        let titleView = hCoreUI.hText("test", style: .standard).foregroundColor(hTextColor.primary)
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        return view
    }
}
