import Flow
import Foundation
import UIKit

public extension UIScrollView {
    var contentSizeSignal: ReadSignal<CGSize> {
        signal(for: \.contentSize)
    }
}
