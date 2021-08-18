import Flow
import Foundation
import UIKit

extension UIView {
    public var safeToPerformEntryAnimationSignal: ReadSignal<Bool> {
        combineLatest(hasWindowSignal, ApplicationContext.shared.$hasFinishedBootstrapping)
            .map { hasWindow, hasBootstrapped in hasWindow && hasBootstrapped }
    }
}
