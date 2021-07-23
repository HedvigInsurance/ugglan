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
    public init(result: MovingFlowResultValue) {
        self.result = result
    }
}


extension MovingFlowResult: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<MovingFlowRoute>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let scrollView = FormScrollView()
        
        let form = FormView()
        
        form.appendSpacing(.top)
        
        let titleLabel = MultilineLabel(value: result.title, style: .brand(.title2(color: .primary)).aligned(to: .center))
        let descriptionLabel = MultilineLabel(
            value: result.description,
            style: .brand(.body(color: .secondary)).aligned(to: .center)
        )
        
        let imageView = UIImageView()
        imageView.image = result.image
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        form.append(imageView)
        form.appendSpacing(.inbetween)
        bag += form.append(titleLabel.insetted(UIEdgeInsets(horizontalInset: 14, verticalInset: 0)))
        form.appendSpacing(.inbetween)
        bag += form.append(descriptionLabel.insetted(UIEdgeInsets(horizontalInset: 14, verticalInset: 0)))
        
        let buttonStack = UIStackView()
        buttonStack.edgeInsets = .init(
            top: 0,
            left: 16,
            bottom: 16 + viewController.view.safeAreaInsets.bottom,
            right: 16
        )
        bag += buttonStack.addArranged(result.button)
        
        bag += viewController.install(form, scrollView: scrollView)
        
        let buttonContainer = UIStackView()
        buttonContainer.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(buttonContainer)
        
        buttonContainer.snp.makeConstraints { make in
            make.bottom.equalTo(
                scrollView.frameLayoutGuide.snp.bottom
            )
            make.trailing.leading.equalToSuperview()
        }
        
        bag += buttonContainer.didLayoutSignal.onValue { _ in
            buttonContainer.layoutMargins = UIEdgeInsets(
                top: 0,
                left: 15,
                bottom: scrollView.safeAreaInsets.bottom == 0
                    ? 15 : scrollView.safeAreaInsets.bottom,
                right: 15
            )
            
            let size = buttonContainer.systemLayoutSizeFitting(
                .zero
            )
            scrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: size.height,
                right: 0
            )
            scrollView.scrollIndicatorInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: size.height,
                right: 0
            )
        }
        
        return (viewController, FiniteSignal { callbacker in
            
            bag += buttonContainer.addArranged(result.button) { control in
                bag += control.signal(for: .touchUpInside).onValue {
                    switch result {
                    case .signed:
                        callbacker(.end)
                    case .chat:
                        callbacker(.value(.chat))
                    }
                }
            }
            
            return bag
        })
    }
}


private extension MovingFlowResultValue {
    var image: UIImage {
        switch self {
        case .signed:
            return hCoreUIAssets.welcome.image
        case .chat:
            return hCoreUIAssets.helicopter.image
        }
    }
    
    var title: String {
        switch self {
        case .signed:
            return L10n.MovingConfirmation.Success.title
        case .chat:
            return L10n.MovingUwFailure.title
        }
    }
    
    var description: String {
        switch self {
        case .signed:
            return L10n.MovingConfirmation.SuccessNoDate.paragraphCopy("")
        case .chat:
            return L10n.MovingUwFailure.paragraph
        }
    }
    
    var button: Button {
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
                type: .standardOutline(borderColor: .brand(.primaryBorderColor), textColor: .brand(.secondaryButtonTextColor))
            )
        }
    }
    
}
