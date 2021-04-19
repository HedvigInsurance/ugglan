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
    
    public init(ids: [String]) {
        self.ids = ids
    }
}

extension Offer: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let form = FormView()
        bag += viewController.install(form)
        
        let firstNameLabel = UILabel(value: "", style: .default)
        form.append(firstNameLabel)
        
        bag += client.fetch(query: GraphQL.QuoteBundleQuery(ids: ids)).onValue({ result in
            firstNameLabel.value = result.quoteBundle.quotes.first?.firstName ?? ""
        })

        return (viewController, bag)
    }
}
