import Foundation
import Presentation
import UIKit

extension UIModalPresentationStyle {
    static var formSheetOrOverFullscreen: UIModalPresentationStyle {
        UIDevice.current.userInterfaceIdiom == .pad
            ? UIModalPresentationStyle.formSheet : UIModalPresentationStyle.overFullScreen
    }
}
