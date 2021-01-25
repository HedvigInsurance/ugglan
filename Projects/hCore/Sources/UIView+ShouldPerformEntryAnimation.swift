import Flow
import Foundation
import UIKit

public extension UIView {
    var safeToPerformEntryAnimationSignal: ReadSignal<Bool> {
        combineLatest(hasWindowSignal, ApplicationContext.shared.$hasFinishedBootstrapping).map { hasWindow, hasBootstrapped in hasWindow && hasBootstrapped }
    }
}
