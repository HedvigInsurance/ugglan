import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public enum MovingFlowResultValue {
	case signed
	case chat
}

public struct MovingFlowResult {
	@Inject var client: ApolloClient
	let result: MovingFlowResultValue
	public init(
		result: MovingFlowResultValue
	) {
		self.result = result
	}
}

extension MovingFlowResult: Presentable {
	public func materialize() -> (UIViewController, FiniteSignal<MovingFlowRoute>) {
		let viewController = UIViewController()
		let bag = DisposeBag()
        
        func image() -> ImageWithOptions {
            return .init(image: result.image, size: nil, contentMode: .scaleAspectFit)
        }

		return (
			viewController,
			FiniteSignal { callbacker in
                
                let imageTextAction = ImageTextAction(image: image(), title: result.title, body: result.description, actions: [(result, result.button)], showLogo: false)
                
                bag += viewController.view.add(imageTextAction) { view in
                    view.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                
                    
                }.onValue { button in
                    switch button {
                    case .signed:
                        callbacker(.end)
                    case .chat:
                        callbacker(.value(.chat))
                    }
                }
                
                return bag
			}
		)
	}
}

extension MovingFlowResultValue {
	fileprivate var image: UIImage {
		switch self {
		case .signed:
			return hCoreUIAssets.welcome.image
		case .chat:
			return hCoreUIAssets.helicopter.image
		}
	}

	fileprivate var title: String {
		switch self {
		case .signed:
			return L10n.MovingConfirmation.Success.title
		case .chat:
			return L10n.MovingUwFailure.title
		}
	}

	fileprivate var description: String {
		switch self {
		case .signed:
			return L10n.MovingConfirmation.SuccessNoDate.paragraphCopy("")
		case .chat:
			return L10n.MovingUwFailure.paragraph
		}
	}

	fileprivate var button: Button {
		switch self {
		case .chat:
			return Button(
				title: L10n.MovingUwFailure.buttonText,
				type: .standardIcon(
					backgroundColor: .brand(.secondaryButtonBackgroundColor),
					textColor: .brand(.secondaryButtonTextColor),
					icon: .left(image: hCoreUIAssets.chat.image, width: 22)
				)
			)
		case .signed:
			return Button(
				title: L10n.MovingConfirmation.Success.buttonText,
				type: .standardOutline(
					borderColor: .brand(.primaryBorderColor),
					textColor: .brand(.primaryButtonTextColor)
				)
			)
		}
	}

}
