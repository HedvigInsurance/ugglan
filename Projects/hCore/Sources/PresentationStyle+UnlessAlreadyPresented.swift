import Foundation
import Presentation
import Flow

extension PresentationStyle {
    /// presents the ViewController unless its already presented
    public static func unlessAlreadyPresented(style: PresentationStyle) -> PresentationStyle {
        PresentationStyle(name: "unlessPresented") { vc, from, options in
            if let presentedTitle = from.presentedViewController?.debugPresentationTitle, presentedTitle == vc.debugPresentationTitle {
                return (Future(), { Future() })
            }
            
            return style.present(vc, from: from, options: options)
        }
    }
}
