import Flow
import Foundation
import SwiftUI

extension UIScrollView { public var contentSizeSignal: ReadSignal<CGSize> { signal(for: \.contentSize) } }
