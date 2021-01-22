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

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 10,
                left: 15,
                bottom: 10,
                right: 15
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .init(all: UIColor.clear.asImage()),
            selectedBackground: .init(all: UIColor.clear.asImage()),
            header: .none,
            footer: .none
        )
        
        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }
        
        viewController.navigationItem.title = "Choose plan"
        
        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)
        
        let tableKit = TableKit<String, PlanRow>(style: style, holdIn: bag)
        
        let containerView = UIView()
        viewController.view = containerView

        containerView.addSubview(tableKit.view)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        
        containerView.addSubview(activityIndicator)
        
        tableKit.view.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let continueButton = Button(title: "Calculate your price", type: .standard(backgroundColor: .black, textColor: .white))
        
        bag += containerView.add(continueButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(containerView).inset(-buttonView.frame.height)
                make.leading.trailing.equalTo(containerView).inset(16)
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
            }
            .atError({ _ in
                
            }).onValue {
                activityIndicator.removeFromSuperview()
                print($0)
                plansSignal.value = $0
            }
    
        bag += plansSignal.atOnce().compactMap { $0 }.onValue { plans in
            
            var table = Table(
                sections: [
                    (
                        "",
                        plans.enumerated().map { offset, story in
                            PlanRow(title: story.localisedTitle, discount: story.discount, message: story.localisedDescription, isSelected: $selectedIndex.map { offset == $0 }.writable(setValue: { isSelected in
                                if isSelected {
                                    $selectedIndex.value = offset
                                }
                            }))
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
        
        
//        bag += continueButton
//            .onTapSignal
//            .withLatestFrom(plansSignal.atOnce().map {
//                $0.first(where: { $0.isSelected == true })
//            }.plain())
//            .compactMap { _, plan in plan }
//            .onValue({ (plan) in
//                viewController.present(Embark(
//                                        name: plan.embarkStory.name,
//                                        state: EmbarkState(externalRedirectHandler: { _ in })))
//            })
                                        
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
        self.metadata.compactMap { $0.asEmbarkStoryMetadataEntryDiscount }.first?.discount
    }
}
