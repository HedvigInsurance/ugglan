import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SnapKit
import UIKit

public struct EmbarkPlans {
    @Inject var client: ApolloClient
    let plansSignal = ReadWriteSignal<[GraphQL.ChoosePlanQuery.Data.EmbarkStory]>([])
    @ReadWriteState var selectedIndex = 0
    
    var selectedPlan: ReadSignal<GraphQL.ChoosePlanQuery.Data.EmbarkStory?> {
        $selectedIndex.withLatestFrom(plansSignal).map { (selected, plans) in
            plans.enumerated().filter { (offset, plan) -> Bool in
                return offset == selected
            }.first?.element
        }
    }
    
    public init() {}
}

extension EmbarkPlans: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let sectionStyle = SectionStyle.defaultStyle
        
        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }
        
        viewController.navigationItem.title = L10n.OnboardingStartpage.screenTitle
        
        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)
        
        let tableKit = TableKit<String, PlanRow>(style: style, holdIn: bag)
        
        let containerView = UIView()
        containerView.backgroundColor = .brand(.primaryBackground())
        viewController.view = containerView

        containerView.addSubview(tableKit.view)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        
        containerView.addSubview(activityIndicator)
        
        let buttonContainerView = UIView()
        buttonContainerView.backgroundColor = .clear
        containerView.addSubview(buttonContainerView)
        
        tableKit.view.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }

        buttonContainerView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(containerView.safeAreaInsets.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(tableKit.view.snp.bottom).offset(20)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let continueButton = Button(
            title: L10n.OnboardingStartpage.continueButtonText,
            type: .standard(
                backgroundColor: UIColor.brand(.secondaryButtonBackgroundColor),
                textColor: UIColor.brand(.secondaryButtonTextColor)
            )
        )
        
        bag += buttonContainerView.add(continueButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(buttonContainerView).inset(-buttonView.frame.height)
                make.top.equalTo(buttonContainerView).inset(20)
                make.leading.trailing.equalTo(buttonContainerView)
            }
            
            bag += buttonView.didMoveToWindowSignal.delay(by: 0.05).take(first: 1).animated(style: SpringAnimationStyle.heavyBounce()) { () in
                let viewHeight = buttonView.systemLayoutSizeFitting(.zero).height + (buttonView.superview?.safeAreaInsets.bottom ?? 0)
                buttonView.transform = CGAffineTransform(translationX: 0, y: -viewHeight)
            }
            
            bag += buttonView.didLayoutSignal.onValue {
                let bottomInset = buttonView.frame.height - buttonView.safeAreaInsets.bottom
                tableKit.view.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            }
        }
        
        bag += client
            .fetch(
                query: GraphQL.ChoosePlanQuery(locale: Localization.Locale.en_NO.code)
            ).valueSignal
            .compactMap { $0.embarkStories }
            .map { $0
                .filter{ story in story.type == .appOnboarding }
            }.onValue {
                activityIndicator.removeFromSuperview()
                plansSignal.value = $0
                $selectedIndex.value = 0
            }
        
        func isSelected(offset: Int) -> ReadWriteSignal<Bool> {
            $selectedIndex.map { offset == $0 }.writable { (isSelected) in
                if isSelected {
                    $selectedIndex.value = offset
                }
            }
        }
    
        bag += plansSignal.atOnce().compactMap { $0 }.onValue { plans in
            
            var table = Table(
                sections: [
                    (
                        "",
                        plans.enumerated().map { offset, story in
                            PlanRow(
                                title: story.localisedTitle,
                                discount: story.discount,
                                message: story.localisedDescription,
                                gradientType: story.gradientViewPreset,
                                isSelected: isSelected(offset: offset)
                            )
                        }
                    ),
                ]
            )
            table.removeEmptySections()
            tableKit.set(table)
        }
        
        bag += continueButton
            .onTapSignal
            .withLatestFrom(selectedPlan.atOnce().plain())
            .compactMap({ (_, story) in return story })
            .onValue({ (story) in
                viewController.present(Embark(
                                        name: story.name,
                                        state: EmbarkState(externalRedirectHandler: { _ in })))
            })
                                        
        return (viewController, bag)
    }
}

private extension GraphQL.ChoosePlanQuery.Data.EmbarkStory {
    var localisedTitle: String {
        switch self.name {
        case "Web Onboarding NO - English Combo":
            return "Bundle"
        case "Web Onboarding NO - English Contents":
            return "Home Contents"
        default:
            return self.name
        }
    }
    
    var localisedDescription: String {
        switch self.name {
        case "Web Onboarding NO - English Combo":
            return "Combination of both contents and travel insurance"
        case "Web Onboarding NO - English Contents":
            return "Contents insurance covers everything in your home"
        default:
            return self.name
        }
    }
    
    var discount: String? {
        self.metadata.compactMap { $0.asEmbarkStoryMetadataEntryPill }.first?.pill
    }
    
    var gradientViewPreset: GradientView.Preset {
        let background = self.metadata.compactMap { $0.asEmbarkStoryMetadataEntryBackground?.background }.first ?? .gradientOne
        
        switch background {
        case .gradientOne:
            return .insuranceOne
        case .gradientTwo:
            return .insuranceTwo
        case .gradientThree:
            return .insuranceThree
        case .__unknown(_):
            return .insuranceOne
        }
    }
}
