import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit
import Apollo
import hGraphQL

public struct Offer {
    @Inject var client: ApolloClient
    let ids: [String]
    let state: OfferState
    
    public init(ids: [String]) {
        self.ids = ids
        self.state = OfferState(ids: ids)
    }
}

struct OfferState {
    @Inject var client: ApolloClient
    let ids: [String]
    
    var dataSignal: CoreSignal<Plain, GraphQL.QuoteBundleQuery.Data> {
        return client.watch(query: GraphQL.QuoteBundleQuery(ids: ids, locale: Localization.Locale.currentLocale.asGraphQLLocale()))
    }
    
    var quotesSignal: CoreSignal<Plain, [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote]> {
        return dataSignal.map { $0.quoteBundle.quotes }
    }
}

extension Offer: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Your offer"
        
        Dependencies.shared.add(module: Module {
            return state
        })
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            DefaultStyling.applyCommonNavigationBarStyling(appearance)
            viewController.navigationItem.standardAppearance = appearance
            viewController.navigationItem.compactAppearance = appearance
        }
        let bag = DisposeBag()
                
        let optionsButton = UIBarButtonItem(image: hCoreUIAssets.menuIcon.image, style: .plain, target: nil, action: nil)

        bag += optionsButton.attachSinglePressMenu(
            viewController: viewController,
            menu: Menu(
                title: nil,
                children: []
            )
        )
        
        viewController.navigationItem.leftBarButtonItem = optionsButton
        
        let scrollView = FormScrollView()
        scrollView.backgroundColor = .brand(.primaryBackground())
        
        let form = FormView()
        form.allowTouchesOfViewsOutsideBounds = true
        form.dynamicStyle = DynamicFormStyle { _ in
            .init(insets: .zero)
        }
        bag += viewController.install(form, scrollView: scrollView)
        
        bag += form.append(Header(scrollView: scrollView))
        bag += form.append(MainContentForm(scrollView: scrollView))
        
        let navigationBarBackgroundView = UIView()
        navigationBarBackgroundView.backgroundColor = .brand(.secondaryBackground())
        navigationBarBackgroundView.alpha = 0
        scrollView.addSubview(navigationBarBackgroundView)
        
        navigationBarBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.frameLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(0)
        }
        
        let navigationBarBorderView = UIView()
        navigationBarBorderView.backgroundColor = .brand(.primaryBorderColor)
        navigationBarBackgroundView.addSubview(navigationBarBorderView)
        
        navigationBarBorderView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(CGFloat.hairlineWidth)
        }
                
        bag += scrollView.didScrollSignal.map { _ in scrollView.contentOffset }.onValue { contentOffset in
            navigationBarBackgroundView.alpha = contentOffset.y / Header.insetTop
            navigationBarBackgroundView.snp.updateConstraints { make in
                if let navigationBar = viewController.navigationController?.navigationBar,
                   let insetTop = viewController.navigationController?.view.safeAreaInsets.top {
                    make.height.equalTo(navigationBar.frame.height + insetTop)
                }
            }
        }

        return (viewController, bag)
    }
}
