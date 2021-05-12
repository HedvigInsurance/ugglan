import Flow
import Foundation
import UIKit

extension UIScrollView { public var contentSizeSignal: ReadSignal<CGSize> { signal(for: \.contentSize) } }
