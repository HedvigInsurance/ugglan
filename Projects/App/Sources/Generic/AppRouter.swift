import Foundation
import Presentation
import Embark
import Flow
import UIKit

struct EmbarkRouting: EmbarkRouter {
    
    func openOffer(viewController: UIViewController) {
        let offer = WebOnboarding(webScreen: .webOffer)
        viewController.present(offer)
    }
    
    func openMailingList(viewController: UIViewController) {
        
    }
}
